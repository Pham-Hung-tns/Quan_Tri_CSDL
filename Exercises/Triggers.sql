-- Tạo bảng để lưu log
CREATE TABLE EmployeeLog (
    log_id INT IDENTITY PRIMARY KEY,
    emp_id VARCHAR(10),
    action_time DATETIME DEFAULT GETDATE()
);

Go
-- Tạo trigger
CREATE TRIGGER trg_AfterInsertEmployee
ON Employee
AFTER INSERT
AS
BEGIN
    INSERT INTO EmployeeLog (emp_id)
    SELECT emp_id FROM INSERTED;
END;


insert into dbo.Employee(emp_id, emp_nm, email, hire_dt, edu_id)
values ('E20033','Hung', 'trangquyh46@gmail.com','2003-12-01',2)

Select * from EmployeeLog

Go
CREATE TRIGGER trg_BeforeInsertEmploye
ON Employee
INSTEAD OF INSERT
AS
BEGIN
    -- Kiểm tra nếu có bản ghi trong INSERTED có email không chứa ký tự @
    IF EXISTS (
        SELECT 1
        FROM INSERTED
        WHERE email NOT LIKE '%@%'
    )
    BEGIN
        RAISERROR('Email phải có @. Xin vui lòng nhập lại', 16, 1);
        ROLLBACK;
    END
    ELSE
    BEGIN
        -- Thực hiện INSERT nếu dữ liệu hợp lệ
        INSERT INTO Employee (emp_id, emp_nm, email, hire_dt, edu_id)
        SELECT emp_id, emp_nm, email, hire_dt, edu_id
        FROM INSERTED;
    END
END;


insert into dbo.Employee(emp_id, emp_nm, email, hire_dt, edu_id)
values ('E20036','Hung_03', 'trangquyh45@gmail.com','2003-12-01',3)

Go
CREATE TRIGGER trg_CheckDatesBeforeInsert
ON EmployeeStatus
INSTEAD OF INSERT
AS
BEGIN
    -- Kiểm tra nếu có bất kỳ bản ghi nào có ngày bắt đầu lớn hơn hoặc bằng ngày kết thúc
    IF EXISTS (
        SELECT 1
        FROM INSERTED
        WHERE start_dt >= end_dt
    )
    BEGIN
        -- Báo lỗi nếu ngày bắt đầu không hợp lệ
        RAISERROR ('Invalid date range. The start date must be earlier than the end date.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END;

    -- Chèn dữ liệu nếu kiểm tra thành công
    INSERT INTO EmployeeStatus (emp_id, job_id, depart_id, manager_id, start_dt, end_dt, addr_id, salary_id)
    SELECT emp_id, job_id, depart_id, manager_id, start_dt, end_dt, addr_id, salary_id
    FROM INSERTED;
END;

SET IDENTITY_INSERT Salary ON
insert into Salary(salary_id, amount)
values(300,2500)
SET IDENTITY_INSERT Salary OFF

insert into dbo.EmployeeStatus(emp_id, job_id, depart_id, manager_id, start_dt, end_dt, addr_id, salary_id)
values ('E20033',10, 2, 'E77884','2003-12-01','2005-12-01',2,300)


SELECT name, type_desc
FROM sys.triggers;

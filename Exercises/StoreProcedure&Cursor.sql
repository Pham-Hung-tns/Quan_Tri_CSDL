-- lấy thông tin của các nhân viên
CREATE PROCEDURE GetEmployeeDetails
AS
BEGIN
    -- Khai báo các biến để lưu thông tin từng nhân viên
    DECLARE @emp_id VARCHAR(10);
    DECLARE @emp_name NVARCHAR(100);
    DECLARE @job_title NVARCHAR(100);
    DECLARE @department NVARCHAR(100);
    DECLARE @salary DECIMAL(18, 2);
    DECLARE @start_dt DATE;
    DECLARE @end_dt DATE;
	DECLARE @job_id INT;
	DECLARE @depart_id INT;

    -- Tạo cursor để duyệt qua bảng Employee_Status
    DECLARE EmployeeCursor CURSOR FOR
    SELECT emp_id, job_id, depart_id, start_dt, end_dt
    FROM EmployeeStatus;

    -- Mở cursor
    OPEN EmployeeCursor;

    -- Lấy dòng đầu tiên từ cursor
    FETCH NEXT FROM EmployeeCursor INTO @emp_id, @job_id, @depart_id, @start_dt, @end_dt;

    -- Vòng lặp qua từng dòng
    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Lấy thông tin từ các bảng liên quan
        SELECT @emp_name = e.emp_nm
        FROM Employee e
        WHERE e.emp_id = @emp_id;

        SELECT @job_title = j.job_title
        FROM Job j
        WHERE j.job_id = @job_id;

        SELECT @department = d.depart_nm
        FROM Department d
        WHERE d.depart_id = @depart_id;

        SELECT @salary = s.amount
        FROM Salary s
        WHERE s.salary_id = (
            SELECT salary_id FROM EmployeeStatus WHERE emp_id = @emp_id AND job_id = @job_id
        );

        -- In ra thông tin nhân viên
        PRINT 'Employee ID: ' + @emp_id;
        PRINT 'Name: ' + @emp_name;
        PRINT 'Job Title: ' + @job_title;
        PRINT 'Department: ' + @department;
        PRINT 'Salary: ' + CAST(@salary AS NVARCHAR(20));
        PRINT 'Start Date: ' + CAST(@start_dt AS NVARCHAR(20));
        PRINT 'End Date: ' + CAST(@end_dt AS NVARCHAR(20));
        PRINT '--------------------------------------';

        -- Lấy dòng tiếp theo
        FETCH NEXT FROM EmployeeCursor INTO @emp_id, @job_id, @depart_id, @start_dt, @end_dt;
    END;

    -- Đóng và xóa cursor
    CLOSE EmployeeCursor;
    DEALLOCATE EmployeeCursor;
END;

-- thực thi
EXEC GetEmployeeDetails;


-- hiệu suất làm việc của nhân viên theo phòng ban
go
CREATE PROCEDURE AnalyzeDepartmentPerformance
AS
BEGIN
    -- Tạo bảng tạm để lưu kết quả
    CREATE TABLE #DepartmentPerformance (
        DepartmentName NVARCHAR(100),
        TotalEmployees INT,
        TotalSalary DECIMAL(18, 2),
        TotalWorkingDays INT
    );

    -- Tính toán tổng số nhân viên, tổng lương, và tổng số ngày làm việc cho từng phòng ban
    INSERT INTO #DepartmentPerformance (DepartmentName, TotalEmployees, TotalSalary, TotalWorkingDays)
    SELECT 
        d.depart_nm AS DepartmentName,
        COUNT(DISTINCT es.emp_id) AS TotalEmployees,
        SUM(s.amount) AS TotalSalary,
        SUM(DATEDIFF(DAY, es.start_dt, ISNULL(es.end_dt, GETDATE()))) AS TotalWorkingDays
    FROM 
        EmployeeStatus es
    JOIN 
        Department d ON es.depart_id = d.depart_id
    JOIN 
        Salary s ON es.salary_id = s.salary_id
    GROUP BY 
        d.depart_nm;

    -- Sử dụng CTE để thêm cột Rank
    WITH RankedDepartments AS (
        SELECT 
            DepartmentName,
            TotalEmployees,
            TotalSalary,
            TotalWorkingDays,
            RANK() OVER (ORDER BY TotalWorkingDays DESC) AS Rank
        FROM 
            #DepartmentPerformance
    )
    SELECT 
        DepartmentName,
        TotalEmployees,
        TotalSalary,
        TotalWorkingDays,
        Rank
    FROM 
        RankedDepartments
    ORDER BY 
        Rank;

    -- Xóa bảng tạm
    DROP TABLE #DepartmentPerformance;
END;


EXEC AnalyzeDepartmentPerformance;
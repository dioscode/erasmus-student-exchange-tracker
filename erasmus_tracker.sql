CREATE TABLE Student (
    StudentID INT PRIMARY KEY,
    FirstName VARCHAR2(50),
    LastName VARCHAR2(50),
    Email VARCHAR2(100),
    Nationality VARCHAR2(50)
);

CREATE TABLE University (
    UniversityID INT PRIMARY KEY,
    Name VARCHAR2(100),
    City VARCHAR2(50),
    Country VARCHAR2(50)
);

CREATE TABLE ExchangeProgram (
    ProgramID INT PRIMARY KEY,
    StudentID INT,
    HomeUniversityID INT,
    HostUniversityID INT,
    StartDate DATE,
    EndDate DATE,
    FOREIGN KEY (StudentID) REFERENCES Student(StudentID),
    FOREIGN KEY (HomeUniversityID) REFERENCES University(UniversityID),
    FOREIGN KEY (HostUniversityID) REFERENCES University(UniversityID)
);

CREATE TABLE Course (
    CourseID INT PRIMARY KEY,
    HostUniversityID INT,
    CourseName VARCHAR2(100),
    Credits INT,
    FOREIGN KEY (HostUniversityID) REFERENCES University(UniversityID)
);

CREATE TABLE Enrollment (
    EnrollmentID INT PRIMARY KEY,
    ProgramID INT,
    CourseID INT,
    Grade VARCHAR2(5),
    FOREIGN KEY (ProgramID) REFERENCES ExchangeProgram(ProgramID),
    FOREIGN KEY (CourseID) REFERENCES Course(CourseID)
);

-- Insert Students
INSERT INTO Student VALUES (3, 'Alice', 'Smith', 'alice@example.com', 'Germany');
INSERT INTO Student VALUES (4, 'Markus', 'Klein', 'markus@example.com', 'Austria');
COMMIT;

-- Insert Universities
INSERT INTO University VALUES (1, 'University of Pécs', 'Pécs', 'Hungary');
INSERT INTO University VALUES (2, 'Humboldt University', 'Berlin', 'Germany');
COMMIT;

-- Insert Exchange Programs
INSERT INTO ExchangeProgram VALUES (1, 3, 2, 1, TO_DATE('2025-02-01', 'YYYY-MM-DD'), TO_DATE('2025-06-30', 'YYYY-MM-DD'));
INSERT INTO ExchangeProgram VALUES (2, 4, 1, 2, TO_DATE('2025-02-01', 'YYYY-MM-DD'), TO_DATE('2025-06-30', 'YYYY-MM-DD'));
COMMIT;

-- Insert Courses
INSERT INTO Course VALUES (1, 1, 'Database Systems', 6);
INSERT INTO Course VALUES (2, 1, 'Hungarian Language Basics', 3);
INSERT INTO Course VALUES (3, 2, 'AI and Ethics', 5);
COMMIT;

-- Insert Enrollments
INSERT INTO Enrollment VALUES (1, 1, 1, 'A');
INSERT INTO Enrollment VALUES (2, 1, 2, 'B');
INSERT INTO Enrollment VALUES (3, 2, 3, 'A');
COMMIT;

CREATE OR REPLACE PROCEDURE EnrollStudent (
    p_ProgramID IN INT,
    p_CourseID IN INT,
    p_Grade IN VARCHAR2
) AS
    v_NewEnrollmentID INT;
BEGIN
    SELECT NVL(MAX(EnrollmentID), 0) + 1 INTO v_NewEnrollmentID FROM Enrollment;
    INSERT INTO Enrollment (EnrollmentID, ProgramID, CourseID, Grade)
    VALUES (v_NewEnrollmentID, p_ProgramID, p_CourseID, p_Grade);
    COMMIT;
END;
/
-- The following trigger is provided for documentation purposes only.
-- It was not executed due to SYS schema restrictions.

CREATE TABLE EnrollmentLog (
    LogID INT PRIMARY KEY,
    EnrollmentID INT,
    LogTime DATE
);

CREATE OR REPLACE TRIGGER trg_LogEnrollment
AFTER INSERT ON Enrollment
FOR EACH ROW
BEGIN
    INSERT INTO EnrollmentLog
    VALUES (
        (SELECT NVL(MAX(LogID), 0) + 1 FROM EnrollmentLog),
        :NEW.EnrollmentID,
        SYSDATE
    );
END;
/
-- sample select query

SELECT s.FirstName, s.LastName, u.Name AS HostUniversity, c.CourseName, e.Grade
FROM Student s
JOIN ExchangeProgram ep ON s.StudentID = ep.StudentID
JOIN University u ON ep.HostUniversityID = u.UniversityID
JOIN Enrollment e ON ep.ProgramID = e.ProgramID
JOIN Course c ON e.CourseID = c.CourseID;

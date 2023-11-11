TRUNCATE TABLE multiuserlogin;
TRUNCATE TABLE feedbacks;
DELETE FROM feedbacks;questions

-- ---------------------------Drop all feedbacks tabels---------------------------------------------
DELIMITER //
CREATE PROCEDURE DropTables()
BEGIN
  DECLARE done INT DEFAULT 0;feedbacksfeedbacks
  DECLARE tableName VARCHAR(255);

  -- Declare a cursor to select table names
  DECLARE cur CURSOR FOR
    SELECT table_name
    FROM information_schema.tables
    WHERE table_name LIKE 'feedback\_%' ESCAPE '\\';

  -- Declare continue handler to exit the loop
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

  OPEN cur;

  read_loop: LOOP
    FETCH cur INTO tableName;

    IF done THEN
      LEAVE read_loop;
    END IF;

    SET @dropTableSQL = CONCAT('DROP TABLE ', tableName);
    PREPARE stmt FROM @dropTableSQL;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
  END LOOP;

  CLOSE cur;
END;
//
DELIMITER ;

CALL DropTables();

DROP PROCEDURE IF EXISTS DropTables;
-- ---------------------------------------------------------------


ALTER TABLE multiuserlogin
ADD PRIMARY KEY (id);

INSERT INTO multiuserlogin VALUES(100,'amey123','Student');
INSERT INTO multiuserlogin VALUES(101,'soham123','Student');
INSERT INTO multiuserlogin VALUES(102,'pratik123','Student');

INSERT INTO multiuserlogin VALUES(1,'fac1','Faculty');
INSERT INTO multiuserlogin VALUES(2,'fac2','Faculty');
INSERT INTO multiuserlogin VALUES(3,'fac3','Faculty');
INSERT INTO multiuserlogin VALUES(4,'fac4','Faculty');

INSERT INTO multiuserlogin VALUES(1001,'admin1','Admin');
INSERT INTO multiuserlogin VALUES(1002,'admin2','Admin');

CREATE TABLE feedbacks (
    feed_id INT PRIMARY KEY AUTO_INCREMENT,
    feed_name VARCHAR(255),
    feed_time TIMESTAMP
);
ALTER TABLE feedbacks
ADD COLUMN by_faculty_id INT;

ALTER TABLE feedbacks
ADD COLUMN no_que INT(11) NULL DEFAULT NULL;


ALTER TABLE feedbacks
ADD CONSTRAINT fk_by_faculty
FOREIGN KEY (by_faculty_id) REFERENCES faculty(faculty_id)
ON UPDATE CASCADE
ON DELETE CASCADE;


CREATE TABLE options (
    ops_type VARCHAR(255),
    ops1 VARCHAR(255),
    ops2 VARCHAR(255),
    ops3 VARCHAR(255),
    ops4 VARCHAR(255),
    ops5 VARCHAR(255)
);

SELECT * FROM feedbacks;
SELECT * FROM feedback_10;
SHOW TABLES;

DELIMITER //
CREATE PROCEDURE `GetStudentFeedbacks` (IN student_prn INT)
BEGIN
    SELECT
    	  f.feed_id,
        f.feed_name AS `Feedback Name`,
        CONCAT(fac.faculty_name, ' (ID: ', f.by_faculty_id, ')') AS `Created By`,
        f.no_que AS `No of Questions`,
        f.feed_time AS `Created On`,
        IFNULL(sf.is_completed, 'pending') AS `Status`
    FROM feedbacks f
    LEFT JOIN std_feedback sf ON f.feed_id = sf.feed_id AND sf.std_prn = student_prn
    LEFT JOIN faculty fac ON f.by_faculty_id = fac.faculty_id;
END//
DELIMITER ;

DELIMITER //
CREATE PROCEDURE `GetQuestionsByFeedId` (IN feedback_id INT)
BEGIN
    SELECT q.que_no, q.question, o.ops1, o.ops2, o.ops3, o.ops4, o.ops5
    FROM questions q
    INNER JOIN options o ON q.ops_type = o.ops_type
    WHERE q.feed_id = feedback_id;
END//
DELIMITER ;

CALL GetQuestionsByFeedId(feed_id);
CALL GetStudentFeedbacks(101);
feedbacks
ALTER TABLE student
MODIFY std_year VARCHAR(10);
student
SELECT * FROM student;
SELECT * FROM faculty;AddStudnet
INSERT INTO faculty (faculty_name, faculty_branch, faculty_id) VALUES (?, ?, ?)
GetStudentFeedbacks




DELIMITER //
CREATE PROCEDURE `GetQuestionsAndOptionsByFeedId` (IN feed_id INT)
BEGIN
    SELECT q.que_no, q.question, o.ops1, o.ops2, o.ops3, o.ops4, o.ops5
    FROM questions q
    INNER JOIN options o ON q.ops_type = o.ops_type
    WHERE q.feed_id = feed_id;
END//
DELIMITER ;

DROP PROCEDURE IF EXISTS GetQuestionsAndOptionsByFeedId;

CALL GetQuestionsAndOptionsByFeedId(4);

DELIMITER //
CREATE PROCEDURE `AddStudent`(
    IN `s_name` VARCHAR(255),
    IN `s_year` VARCHAR(10),
    IN `s_roll` INT,
    IN `s_branch` VARCHAR(255),
    IN `password` VARCHAR(16),
    IN `s_prn` INT
)
LANGUAGE SQL
NOT DETERMINISTIC
CONTAINS SQL
SQL SECURITY DEFINER
COMMENT ''
BEGIN
    -- Declare a variable for the new student ID and branch ID
    -- DECLARE new_std_id INT;
    DECLARE new_branch_id INT;

    -- Get the branch_id based on the branch_name
    SELECT branch_id INTO new_branch_id FROM branches WHERE branch_name = s_branch LIMIT 1;
	 SELECT new_branch_id;
    -- Insert a new row into the multiuserlogin table to generate a new student ID
    INSERT INTO multiuserlogin (ID ,Password, Role)
    VALUES (s_prn, password, 'student');

    -- Get the auto-genAddStudenterated student ID
    -- SET new_std_id = LAST_INSERT_ID();

    -- Insert a new row into the student table with the generated student ID and the resolved branch ID
    INSERT INTO student (std_name, std_year, std_rollno, std_prn, branch_id)
    VALUES (s_name, s_year, s_roll, s_prn, new_branch_id);

    -- Commit the transaction
    COMMIT;
END//
DELIMITER ;


SELECT * FROM Std_Feedback_Responses;
CALL GetStudentFeedbacks(10);

CREATE TABLE Std_Feedback_Responses (
    std_prn INT,
    feed_Id INT,
    que_no INT,
    ops_selected VARCHAR(255),
    FOREIGN KEY (std_prn) REFERENCES student (std_prn) ON DELETE CASCADE,
    FOREIGN KEY (que_no) REFERENCES questions (que_no) ON DELETE CASCADE,
    FOREIGN KEY (feed_Id) REFERENCES questions (feed_Id) ON DELETE CASCADE
);

ALTER TABLE Std_Feedback_ResponsesmultiuserloginAddStudnet ADD PRIMARY KEY (std_prn,que_no,feed_Id);

INSERT INTO Std_Feedback_Responses (std_prn, feed_Id, que_no, ops_selected) VALUES (101, 10, 1, 'ops3');
Std_Feedback_Responses
SELECT * FROM Std_Feedback_Responses;

ALTER TABLE Std_Feedback_Responses ADD is_given TINYINT(0);

TRUNCATE TABLE Std_Feedback_Responses;

GetQuestionsAndOptionsByFeedId
CALL GetQuestionByFeedId(20,1);

SELECT
    SUM(CASE WHEN ops_selected = 'ops1' THEN 1 ELSE 0 END) AS ops1_count,
    SUM(CASE WHEN ops_selected = 'ops2' THEN 1 ELSE 0 END) AS ops2_count,
    SUM(CASE WHEN ops_selected = 'ops3' THEN 1 ELSE 0 END) AS ops3_count,
    SUM(CASE WHEN ops_selected = 'ops4' THEN 1 ELSE 0 END) AS ops4_count,
    SUM(CASE WHEN ops_selected = 'ops5' THEN 1 ELSE 0 END) AS ops5_count
FROM Std_Feedback_Responses
WHERE feed_id = 22 AND que_no = 1;

(SELECT COUNT(std_prn) FROM std_feedback WHERE feed_id = 21 AND is_completed = 'completed') AS unique_std_prn_count_completed


SELECT 
    (SELECT COUNT(std_prn) FROM student) AS unique_std_prn_count_total,
    (SELECT COUNT(std_prn) FROM std_feedback WHERE feed_id = 20 AND is_completed = 'completed') AS unique_std_prn_count_completed;


SELECT
    feedbacks.*,
    (
        SELECT COUNT(DISTINCT std_prn)
        FROM std_feedback
        WHERE feed_id = feedbacks.feed_id
        AND is_completed = 'completed'
    ) AS unique_std_prn_count_completed
FROM feedbacks
WHERE by_faculty_Id = 1024;


DELIMITER //
CREATE PROCEDURE InsertStudent(
    IN std_name VARCHAR(255),
    IN std_year VARCHAR(10),
    IN std_rollno INT,
    IN std_prn INT,
    IN branch_id INT
)
BEGIN
    INSERT INTO student (std_name, std_year, std_rollno, std_prn, branch_id)
    VALUES (std_name, std_year, std_rollno, std_prn, branch_id);
END //
DELIMITER ;multiuserlogin

CALL InsertStudent('Swapnil Gawali', '3rd', 51, 1220284, 2);InsertStudent

INSERT INTO multiuserlogin VALUES (44444, "password", "Student");

CALL AddStudent('Swapnil Gawali', '2nd', 51, 'Chemical Engineering', 'pass', 12220278);

DELIMITER //
CREATE PROCEDURE `AddStudent2`(
    IN `s_name` VARCHAR(255),
    IN `s_year` VARCHAR(10),
    IN `s_branch` VARCHAR(255),
    IN `s_roll` INT,
    IN `s_prn` INT,
    IN `password` VARCHAR(16)
)
LANGUAGE SQL
NOT DETERMINISTIC
CONTAINS SQL
SQL SECURITY DEFINER
COMMENT ''
BEGIN
	 -- Declare a variable for the new student ID and branch ID
    -- DECLARE new_std_id INT;
    
    -- Declare a variable for the new student ID and branch ID
    DECLARE new_branch_id INT;

    -- Get the branch_id based on the branch_name
    SELECT branch_id INTO new_branch_id FROM branches WHERE branch_name = s_branch LIMIT 1;

    -- If s_prn is 0, set it to NULL to allow the database to auto-increment
    IF s_prn = 0 THEN
            -- Get the auto-genAddStudenterated student ID
         -- SET new_std_id = LAST_INSERT_ID();
         SET s_prn = LAST_INSERT_ID()+1;
    		-- SET s_prn = LAST_INSERT_ID()+1;
    END IF;
	
    -- Insert a new row into the multiuserlogin table to generate a new student ID
	 INSERT INTO multiuserlogin (ID ,Password, Role)
    VALUES (s_prn, password, 'student');
	
    -- Insert a new row into the student table with the generated student ID and the resolved branch ID
    INSERT INTO student (std_name, std_year, std_rollno, std_prn, branch_id)
    VALUES (s_name, s_year, s_roll, s_prn, new_branch_id);

    -- Commit the transaction
    COMMIT;
END//
DELIMITER ;

CALL AddStudent2("Shakira singer", '4th', "Computer Science", 76, 0, "shakira123");



DELIMITER //
CREATE PROCEDURE `AddFaculty`(
  	 IN `f_id` INT ,
    IN `f_name` VARCHAR(255),
	 IN `f_branch` VARCHAR(255),
    IN `f_email` VARCHAR(255),
    IN `f_password` VARCHAR(16)
)
LANGUAGE SQL
NOT DETERMINISTIC
CONTAINS SQL
SQL SECURITY DEFINER
COMMENT ''
BEGIN
    -- Declare a variable for the new student ID and branch ID
    -- DECLARE new_faculty_id INT;
    DECLARE new_branch_id INT;

    -- Get the branch_id based on the branch_name
    SELECT branch_id INTO new_branch_id FROM branches WHERE branch_name = f_branch LIMIT 1;
	 SELECT new_branch_id;
    
    
    INSERT INTO multiuserlogin (ID, Password, Role)
    VALUES (f_id, f_password, 'faculty');
    
    -- SET new_faculty_id = LAST_INSERT_ID();

   
    INSERT INTO faculty (faculty_name, faculty_id, branch_id, email)
    VALUES (f_name, f_id, new_branch_id, f_email);

    -- Commit the transaction
    COMMIT;
END//
DELIMITER ;
SELECT * FROM std_feedback;
SELECT q.question FROM questions q WHERE feed_id = 11 AND que_no = 1;

CREATE TABLE `Std_Feedback_Responses` (
    `std_prn` INT NOT NULL,
    `feed_Id` INT NOT NULL,
    `que_no` INT NOT NULL,GetQuestionsByFeedId
    `ops_selected` VARCHAR(255) NOT NULL,
    PRIMARY KEY (`std_prn`, `feed_Id`, `que_no`),
    FOREIGN KEY (`std_prn`) REFERENCES student(`std_prn`) ON DELETE CASCADE,
    FOREIGN KEY (`feed_Id`) REFERENCES feedbacks(`feed_id`) ON DELETE CASCADE,
    FOREIGN KEY (`que_no`) REFERENCES questions(`que_no`) ON DELETE CASCADE
);

DELIMITER //
CREATE DEFINER=`sql12658745`@`%` PROCEDURE `GetQuestionByFeedId`(
    IN `feedback_id` INT,
    IN `question_number` INT
)
BEGIN
    SELECT q.que_no, q.question, o.ops1, o.ops2, o.ops3, o.ops4, o.ops5
    FROM questions q
    INNER JOIN options o ON q.ops_type = o.ops_type
    WHERE q.feed_id = feedback_id AND q.que_no = question_number;
END //
DELIMITER ;



SELECT feedbacks.* ,
( SELECT COUNT(DISTINCT std_prn) FROM std_feedstd_feedbackback WHERE feed_id = feedbacks.feed_id AND is_completed = 'completed') AS responses
FROM feedbacks
WHERE by_faculty_Id = 101;

DELIMITER //
CREATE DEFINER=`sql12658745`@`%` PROCEDURE `RemoveFeedbackForAllStudents`(
    IN `feedback_id` INT
)
LANGUAGE SQL
NOT DETERMINISTIC
CONTAINS SQL
SQL SECURITY DEFINER
COMMENT ''
BEGIN
    -- Start the transaction
    START TRANSACTION;

    -- Delete feedback for all students with the specified `feedback_id`
    DELETE FROM std_feedback WHERE feed_id = feedback_id;

    -- Update the `feed_status` to 'Not Published' (or another desired value) for the specified `feedback_id`
    UPDATE feedbacks SET feed_status = 'Unpublished' WHERE feed_id = feedback_id;
    
    DELETE FROM Std_Feedback_Responses WHERE feed_id = feedback_id;

    -- Commit the transaction
    COMMIT;
END //
DELIMITER ;

    
    

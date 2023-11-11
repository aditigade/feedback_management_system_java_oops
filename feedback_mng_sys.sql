-- --------------------------------------------------------
-- Host:                         sql12.freemysqlhosting.net
-- Server version:               5.5.62-0ubuntu0.14.04.1 - (Ubuntu)
-- Server OS:                    debian-linux-gnu
-- HeidiSQL Version:             12.5.0.6677
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

-- Dumping structure for procedure sql12658745.AddFaculty
DELIMITER //
CREATE PROCEDURE `AddFaculty`(
  	 IN `f_id` INT ,
    IN `f_name` VARCHAR(255),
	 IN `f_branch` VARCHAR(255),
    IN `f_email` VARCHAR(255),
    IN `f_password` VARCHAR(16)
)
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

-- Dumping structure for procedure sql12658745.AddFeedbackForAllStudents
DELIMITER //
CREATE PROCEDURE `AddFeedbackForAllStudents`(
    IN `feedback_id` INT
)
BEGIN
    -- Declare variables
    DECLARE done INT DEFAULT 0;
    DECLARE student_prn INT;

    -- Declare cursor for selecting all student PRNs
    DECLARE student_cursor CURSOR FOR
        SELECT std_prn FROM student;

    -- Continue handling until there are no more students
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    -- Start the transaction
    START TRANSACTION;

    OPEN student_cursor;

    student_loop: LOOP
        FETCH student_cursor INTO student_prn;

        IF done = 1 THEN
            LEAVE student_loop;
        END IF;

        -- Insert a new row into std_feedback for each student
        INSERT INTO std_feedback (std_prn, feed_id, is_completed)
        VALUES (student_prn, feedback_id, 'pending');
    END LOOP;

    CLOSE student_cursor;

    -- Update the feed_status to 'Published'
    UPDATE feedbacks SET feed_status = 'Published' WHERE feed_id = feedback_id;

    -- Commit the transaction
    COMMIT;
END//
DELIMITER ;

-- Dumping structure for procedure sql12658745.AddStudent
DELIMITER //
CREATE PROCEDURE `AddStudent`(
    IN `s_name` VARCHAR(255),
    IN `s_year` VARCHAR(10),
	 IN `s_branch` VARCHAR(255),
    IN `s_roll` INT,
    IN `s_prn` INT,
    IN `password` VARCHAR(16)
)
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

-- Dumping structure for table sql12658745.branches
CREATE TABLE IF NOT EXISTS `branches` (
  `branch_id` int(11) NOT NULL AUTO_INCREMENT,
  `branch_name` varchar(255) NOT NULL,
  PRIMARY KEY (`branch_id`),
  UNIQUE KEY `branch_name` (`branch_name`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=latin1;

-- Dumping data for table sql12658745.branches: ~7 rows (approximately)
DELETE FROM `branches`;
INSERT INTO `branches` (`branch_id`, `branch_name`) VALUES
	(12, 'Artificial Intelligence and Data Science'),
	(10, 'Chemical Engineering'),
	(9, 'Civil Engineering'),
	(6, 'Computer Science'),
	(7, 'Electrical Engineering'),
	(11, 'Information Technology'),
	(8, 'Mechanical Engineering');

-- Dumping structure for table sql12658745.faculty
CREATE TABLE IF NOT EXISTS `faculty` (
  `faculty_name` varchar(255) DEFAULT NULL,
  `faculty_id` int(11) NOT NULL AUTO_INCREMENT,
  `branch_id` int(11) DEFAULT NULL,
  `email` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`faculty_id`),
  KEY `branch_id` (`branch_id`),
  CONSTRAINT `faculty_ibfk_1` FOREIGN KEY (`faculty_id`) REFERENCES `multiuserlogin` (`ID`) ON DELETE CASCADE,
  CONSTRAINT `faculty_ibfk_2` FOREIGN KEY (`branch_id`) REFERENCES `branches` (`branch_id`)
) ENGINE=InnoDB AUTO_INCREMENT=12320094 DEFAULT CHARSET=latin1;

-- Dumping data for table sql12658745.faculty: ~6 rows (approximately)
DELETE FROM `faculty`;
INSERT INTO `faculty` (`faculty_name`, `faculty_id`, `branch_id`, `email`) VALUES
	('Dr. Aparna Sharma', 101, 10, 'aparna.sharma@vit.edu'),
	('Prof. Rajesh Kumar', 102, 12, 'rajesh.kumar@vit.edu'),
	('Dr. Priya Patel', 103, 6, 'priya.patel@vit.edu'),
	('Prof. Sanjay Choudhary', 104, 8, 'sanjay.choudhary@vit.edu'),
	('Prof. Vikram Singh', 105, 9, 'vikram.singh@vit.edu'),
	('Dr. Anjali Verma', 106, 12, 'anjali.verma@vit.edu');

-- Dumping structure for view sql12658745.FacultyList
-- Creating temporary table to overcome VIEW dependency errors
CREATE TABLE `FacultyList` (
	`faculty_id` INT(11) NOT NULL,
	`faculty_name` VARCHAR(255) NULL COLLATE 'latin1_swedish_ci',
	`email` VARCHAR(50) NULL COLLATE 'latin1_swedish_ci',
	`branch_name` VARCHAR(255) NOT NULL COLLATE 'latin1_swedish_ci',
	`Password` VARCHAR(16) NOT NULL COLLATE 'latin1_swedish_ci'
) ENGINE=MyISAM;

-- Dumping structure for table sql12658745.feedbacks
CREATE TABLE IF NOT EXISTS `feedbacks` (
  `feed_id` int(11) NOT NULL AUTO_INCREMENT,
  `feed_name` varchar(255) DEFAULT NULL,
  `feed_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `by_faculty_id` int(11) DEFAULT NULL,
  `no_que` int(11) DEFAULT NULL,
  `feed_status` varchar(255) DEFAULT 'Not Published',
  PRIMARY KEY (`feed_id`),
  KEY `fk_by_faculty` (`by_faculty_id`),
  CONSTRAINT `fk_by_faculty` FOREIGN KEY (`by_faculty_id`) REFERENCES `faculty` (`faculty_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=25 DEFAULT CHARSET=latin1;

-- Dumping data for table sql12658745.feedbacks: ~3 rows (approximately)
DELETE FROM `feedbacks`;
INSERT INTO `feedbacks` (`feed_id`, `feed_name`, `feed_time`, `by_faculty_id`, `no_que`, `feed_status`) VALUES
	(21, 'Instructor Evaluation Feedback', '2023-11-03 07:07:27', 101, 6, 'Published'),
	(22, 'Employee Performance Review Feedback', '2023-11-03 07:07:35', 101, 6, 'Published'),
	(23, 'Customer Satisfaction Feedback', '2023-11-03 07:05:04', 101, 3, 'Published');

-- Dumping structure for procedure sql12658745.GetQuestionByFeedId
DELIMITER //
CREATE PROCEDURE `GetQuestionByFeedId`(
    IN `feedback_id` INT,
    IN `question_number` INT
)
BEGIN
    SELECT q.que_no, q.question, o.ops1, o.ops2, o.ops3, o.ops4, o.ops5
    FROM questions q
    INNER JOIN options o ON q.ops_type = o.ops_type
    WHERE q.feed_id = feedback_id AND q.que_no = question_number;
END//
DELIMITER ;

-- Dumping structure for procedure sql12658745.GetQuestionsAndOptionsByFeedId
DELIMITER //
CREATE PROCEDURE `GetQuestionsAndOptionsByFeedId`(IN feed_id INT)
BEGIN
    SELECT q.que_no, q.question, o.ops1, o.ops2, o.ops3, o.ops4, o.ops5
    FROM questions q
    INNER JOIN options o ON q.ops_type = o.ops_type
    WHERE q.feed_id = feed_id;
END//
DELIMITER ;

-- Dumping structure for procedure sql12658745.GetQuestionsByFeedId
DELIMITER //
CREATE PROCEDURE `GetQuestionsByFeedId`(IN feedback_id INT)
BEGIN
    SELECT q.que_no, q.question, o.ops1, o.ops2, o.ops3, o.ops4, o.ops5
    FROM questions q
    INNER JOIN options o ON q.ops_type = o.ops_type
    WHERE q.feed_id = feedback_id;
END//
DELIMITER ;

-- Dumping structure for table sql12658745.multiuserlogin
CREATE TABLE IF NOT EXISTS `multiuserlogin` (
  `ID` int(50) NOT NULL AUTO_INCREMENT,
  `Password` varchar(16) NOT NULL,
  `Role` varchar(20) NOT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB AUTO_INCREMENT=12320096 DEFAULT CHARSET=latin1;

-- Dumping data for table sql12658745.multiuserlogin: ~27 rows (approximately)
DELETE FROM `multiuserlogin`;
INSERT INTO `multiuserlogin` (`ID`, `Password`, `Role`) VALUES
	(101, 'fac1', 'faculty'),
	(102, 'fac2', 'faculty'),
	(103, 'fac3', 'faculty'),
	(104, 'fac4', 'faculty'),
	(105, 'fac5', 'faculty'),
	(106, 'fac6', 'faculty'),
	(1001, 'admin1', 'admin'),
	(12320001, 'std1', 'student'),
	(12320002, 'std2', 'student'),
	(12320003, 'std3', 'student'),
	(12320004, 'std4', 'student'),
	(12320005, 'std5', 'student'),
	(12320006, 'std6', 'student'),
	(12320007, 'std7', 'student'),
	(12320008, 'std8', 'student'),
	(12320009, 'std9', 'student'),
	(12320010, 'std10', 'student'),
	(12320011, 'std11', 'student'),
	(12320012, 'std12', 'student'),
	(12320013, 'std13', 'student'),
	(12320014, 'std14', 'student'),
	(12320015, 'std15', 'student'),
	(12320016, 'std16', 'student'),
	(12320017, 'std17', 'student'),
	(12320018, 'std18', 'student'),
	(12320019, 'std19', 'student'),
	(12320020, 'std20', 'student');

-- Dumping structure for table sql12658745.options
CREATE TABLE IF NOT EXISTS `options` (
  `ops_type` varchar(255) NOT NULL DEFAULT '',
  `ops1` varchar(255) DEFAULT NULL,
  `ops2` varchar(255) DEFAULT NULL,
  `ops3` varchar(255) DEFAULT NULL,
  `ops4` varchar(255) DEFAULT NULL,
  `ops5` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`ops_type`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Dumping data for table sql12658745.options: ~19 rows (approximately)
DELETE FROM `options`;
INSERT INTO `options` (`ops_type`, `ops1`, `ops2`, `ops3`, `ops4`, `ops5`) VALUES
	('Adaptability', 'Quick to Adapt', 'Flexible', 'Adjustable', 'Slow to Adapt', 'Resistant to Change'),
	('Availability for Office Hours', 'Always Available', 'Often Available', 'Occasionally Available', 'Rarely Available', 'Never Available'),
	('Clarity of Instruction', 'Very Clear', 'Clear', 'Somewhat Clear', 'Unclear', 'Very Unclear'),
	('Classroom Engagement and Interaction', 'Highly Engaging', 'Engaging', 'Somewhat Engaging', 'Not Very Engaging', 'Not Engaging at All'),
	('Communication Skills', 'Excellent', 'Good', 'Adequate', 'Needs Improvement', 'Poor'),
	('Conflict Resolution', 'Skilled', 'Effective', 'Mediocre', 'Ineffective', 'Unable to Resolve'),
	('Creativity', 'Innovative', 'Imaginative', 'Resourceful', 'Conventional', 'Unimaginative'),
	('Feedback on Assignments and Assessments', 'Detailed and Timely', 'Timely but Lacks Detail', 'Somewhat Timely and Detailed', 'Delayed and Lacks Detail', 'No Feedback Provided'),
	('Leadership Abilities', 'Strong', 'Decent', 'Moderate', 'Weak', 'Ineffective'),
	('Overall Teaching Effectiveness', 'Excellent', 'Very Good', 'Good', 'Fair', 'Poor'),
	('Problem-Solving Skills', 'Outstanding', 'Resourceful', 'Capable', 'Limited', 'Inadequate'),
	('Project Management', 'Organized', 'Efficient', 'Satisfactory', 'Disorganized', 'Chaotic'),
	('Recommend to Others', 'Definitely', 'Probably', 'Not Sure', 'Probably Not', 'Definitely Not'),
	('Responsiveness to Student Questions', 'Very Responsive', 'Responsive', 'Somewhat Responsive', 'Not Very Responsive', 'Unresponsive'),
	('Satisfaction', 'Very Satisfied', 'Satisfied', 'Neutral', 'Dissatisfied', 'Very Dissatisfied'),
	('Teamwork', 'Collaborative', 'Cooperative', 'Contributory', 'Detrimental', 'Non-Participative'),
	('Technical Knowledge', 'Expert', 'Proficient', 'Competent', 'Novice', 'Inexperienced'),
	('Time Management', 'Exceptional', 'Effective', 'Satisfactory', 'Room for Improvement', 'Inefficient'),
	('Use of Technology in Teaching', 'Highly Effective', 'Effective', 'Adequate', 'Ineffective', 'No Use of Technology');

-- Dumping structure for table sql12658745.questions
CREATE TABLE IF NOT EXISTS `questions` (
  `que_no` int(11) NOT NULL DEFAULT '0',
  `feed_id` int(11) NOT NULL DEFAULT '0',
  `question` varchar(255) DEFAULT NULL,
  `ops_type` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`que_no`,`feed_id`),
  KEY `feed_id` (`feed_id`),
  KEY `ops_type` (`ops_type`),
  CONSTRAINT `questions_ibfk_1` FOREIGN KEY (`feed_id`) REFERENCES `feedbacks` (`feed_id`) ON DELETE CASCADE,
  CONSTRAINT `questions_ibfk_2` FOREIGN KEY (`ops_type`) REFERENCES `options` (`ops_type`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Dumping data for table sql12658745.questions: ~15 rows (approximately)
DELETE FROM `questions`;
INSERT INTO `questions` (`que_no`, `feed_id`, `question`, `ops_type`) VALUES
	(1, 21, 'How would you rate the instructor\'s Communication Skills?', 'Communication Skills'),
	(1, 22, 'How well does the employee demonstrate Leadership Abilities within the organization?', 'Leadership Abilities'),
	(1, 23, 'How would you rate the overall quality of our product/service?', 'Overall Teaching Effectiveness'),
	(2, 21, ' How satisfied are you with the instructor\'s Responsiveness to Student Questions?', 'Responsiveness to Student Questions'),
	(2, 22, ' Rate the employee\'s Problem-Solving Skills', 'Problem-Solving Skills'),
	(2, 23, 'Were you satisfied with the level of customer support you received?', 'Technical Knowledge'),
	(3, 21, 'Please rate the instructor\'s Creativity in teaching.', 'Creativity'),
	(3, 22, 'Please evaluate the employee\'s Adaptability to changing work conditions.', 'Adaptability'),
	(3, 23, 'Would you recommend our product/service to others?', 'Responsiveness to Student Questions'),
	(4, 21, 'How do you assess the instructor\'s Classroom Engagement and Interaction?', 'Classroom Engagement and Interaction'),
	(4, 22, 'How satisfied are you with the employee\'s Time Management skills?', 'Time Management'),
	(5, 21, 'Rate the instructor\'s Technical Knowledge', 'Technical Knowledge'),
	(5, 22, 'Assess the employee\'s Teamwork capabilities.', 'Teamwork'),
	(6, 21, 'Evaluate the instructor\'s Time Management skills.', 'Time Management'),
	(6, 22, 'Please rate the employee\'s Communication Skills.', 'Communication Skills');

-- Dumping structure for procedure sql12658745.RemoveFeedbackForAllStudents
DELIMITER //
CREATE PROCEDURE `RemoveFeedbackForAllStudents`(
    IN `feedback_id` INT
)
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
END//
DELIMITER ;

-- Dumping structure for table sql12658745.std_feedback
CREATE TABLE IF NOT EXISTS `std_feedback` (
  `std_prn` int(11) NOT NULL DEFAULT '0',
  `feed_id` int(11) NOT NULL DEFAULT '0',
  `is_completed` varchar(10) DEFAULT NULL,
  PRIMARY KEY (`std_prn`,`feed_id`),
  KEY `feed_id` (`feed_id`),
  CONSTRAINT `std_feedback_ibfk_1` FOREIGN KEY (`std_prn`) REFERENCES `student` (`std_prn`) ON DELETE CASCADE,
  CONSTRAINT `std_feedback_ibfk_2` FOREIGN KEY (`feed_id`) REFERENCES `feedbacks` (`feed_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Dumping data for table sql12658745.std_feedback: ~20 rows (approximately)
DELETE FROM `std_feedback`;
INSERT INTO `std_feedback` (`std_prn`, `feed_id`, `is_completed`) VALUES
	(12320001, 21, 'pending'),
	(12320001, 22, 'completed'),
	(12320001, 23, 'completed'),
	(12320002, 21, 'completed'),
	(12320002, 22, 'pending'),
	(12320002, 23, 'completed'),
	(12320003, 21, 'pending'),
	(12320003, 22, 'completed'),
	(12320003, 23, 'completed'),
	(12320004, 21, 'completed'),
	(12320004, 22, 'pending'),
	(12320004, 23, 'completed'),
	(12320005, 21, 'pending'),
	(12320005, 22, 'completed'),
	(12320005, 23, 'completed'),
	(12320006, 21, 'pending'),
	(12320006, 22, 'completed'),
	(12320006, 23, 'completed'),
	(12320007, 21, 'completed'),
	(12320007, 22, 'pending'),
	(12320007, 23, 'completed'),
	(12320008, 21, 'completed'),
	(12320008, 22, 'completed'),
	(12320008, 23, 'pending'),
	(12320009, 21, 'pending'),
	(12320009, 22, 'completed'),
	(12320009, 23, 'pending'),
	(12320010, 21, 'pending'),
	(12320010, 22, 'pending'),
	(12320010, 23, 'pending'),
	(12320011, 21, 'pending'),
	(12320011, 22, 'pending'),
	(12320011, 23, 'pending'),
	(12320012, 21, 'completed'),
	(12320012, 22, 'completed'),
	(12320012, 23, 'completed'),
	(12320013, 21, 'completed'),
	(12320013, 22, 'completed'),
	(12320013, 23, 'pending'),
	(12320014, 21, 'completed'),
	(12320014, 22, 'completed'),
	(12320014, 23, 'completed'),
	(12320015, 21, 'pending'),
	(12320015, 22, 'pending'),
	(12320015, 23, 'pending'),
	(12320016, 21, 'pending'),
	(12320016, 22, 'completed'),
	(12320016, 23, 'completed'),
	(12320017, 21, 'pending'),
	(12320017, 22, 'completed'),
	(12320017, 23, 'completed'),
	(12320018, 21, 'pending'),
	(12320018, 22, 'pending'),
	(12320018, 23, 'pending'),
	(12320019, 21, 'completed'),
	(12320019, 22, 'pending'),
	(12320019, 23, 'completed'),
	(12320020, 21, 'pending'),
	(12320020, 22, 'completed'),
	(12320020, 23, 'pending');

-- Dumping structure for table sql12658745.Std_Feedback_Responses
CREATE TABLE IF NOT EXISTS `Std_Feedback_Responses` (
  `std_prn` int(11) NOT NULL,
  `feed_Id` int(11) NOT NULL,
  `que_no` int(11) NOT NULL,
  `ops_selected` varchar(255) NOT NULL,
  KEY `Std_Feedback_Responses_ibfk_1` (`std_prn`),
  KEY `Std_Feedback_Responses_ibfk_2` (`feed_Id`),
  KEY `Std_Feedback_Responses_ibfk_3` (`que_no`),
  CONSTRAINT `Std_Feedback_Responses_ibfk_1` FOREIGN KEY (`std_prn`) REFERENCES `student` (`std_prn`) ON DELETE CASCADE,
  CONSTRAINT `Std_Feedback_Responses_ibfk_2` FOREIGN KEY (`feed_Id`) REFERENCES `feedbacks` (`feed_id`) ON DELETE CASCADE,
  CONSTRAINT `Std_Feedback_Responses_ibfk_3` FOREIGN KEY (`que_no`) REFERENCES `questions` (`que_no`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Dumping data for table sql12658745.Std_Feedback_Responses: ~99 rows (approximately)
DELETE FROM `Std_Feedback_Responses`;
INSERT INTO `Std_Feedback_Responses` (`std_prn`, `feed_Id`, `que_no`, `ops_selected`) VALUES
	(12320001, 22, 1, 'ops2'),
	(12320001, 22, 2, 'ops1'),
	(12320001, 22, 3, 'ops3'),
	(12320001, 22, 4, 'ops4'),
	(12320001, 22, 5, 'ops1'),
	(12320001, 22, 6, 'ops4'),
	(12320001, 23, 1, 'ops1'),
	(12320001, 23, 2, 'ops4'),
	(12320001, 23, 3, 'ops5'),
	(12320002, 21, 1, 'ops3'),
	(12320002, 21, 2, 'ops1'),
	(12320002, 21, 3, 'ops4'),
	(12320002, 21, 4, 'ops5'),
	(12320002, 21, 5, 'ops3'),
	(12320002, 21, 6, 'ops4'),
	(12320002, 23, 1, 'ops1'),
	(12320002, 23, 2, 'ops2'),
	(12320002, 23, 3, 'ops3'),
	(12320003, 23, 1, 'ops2'),
	(12320003, 23, 2, 'ops5'),
	(12320003, 23, 3, 'ops3'),
	(12320003, 22, 1, 'ops3'),
	(12320003, 22, 2, 'ops1'),
	(12320003, 22, 3, 'ops4'),
	(12320003, 22, 4, 'ops5'),
	(12320003, 22, 5, 'ops2'),
	(12320003, 22, 6, 'ops1'),
	(12320004, 21, 1, 'ops2'),
	(12320004, 21, 2, 'ops4'),
	(12320004, 21, 3, 'ops1'),
	(12320004, 21, 4, 'ops4'),
	(12320004, 21, 5, 'ops5'),
	(12320004, 21, 6, 'ops3'),
	(12320004, 23, 1, 'ops1'),
	(12320004, 23, 2, 'ops3'),
	(12320004, 23, 3, 'ops4'),
	(12320005, 23, 1, 'ops3'),
	(12320005, 23, 2, 'ops1'),
	(12320005, 23, 3, 'ops4'),
	(12320005, 22, 1, 'ops3'),
	(12320005, 22, 2, 'ops1'),
	(12320005, 22, 3, 'ops4'),
	(12320005, 22, 4, 'ops5'),
	(12320005, 22, 5, 'ops2'),
	(12320005, 22, 6, 'ops3'),
	(12320006, 23, 1, 'ops2'),
	(12320006, 23, 2, 'ops4'),
	(12320006, 23, 3, 'ops1'),
	(12320006, 22, 1, 'ops2'),
	(12320006, 22, 2, 'ops1'),
	(12320006, 22, 3, 'ops3'),
	(12320006, 22, 4, 'ops5'),
	(12320006, 22, 5, 'ops4'),
	(12320006, 22, 6, 'ops1'),
	(12320007, 23, 1, 'ops2'),
	(12320007, 23, 2, 'ops1'),
	(12320007, 23, 3, 'ops4'),
	(12320007, 21, 1, 'ops1'),
	(12320007, 21, 2, 'ops3'),
	(12320007, 21, 3, 'ops5'),
	(12320007, 21, 4, 'ops4'),
	(12320007, 21, 5, 'ops2'),
	(12320007, 21, 6, 'ops4'),
	(12320008, 22, 1, 'ops3'),
	(12320008, 22, 2, 'ops4'),
	(12320008, 22, 3, 'ops1'),
	(12320008, 22, 4, 'ops5'),
	(12320008, 22, 5, 'ops1'),
	(12320008, 22, 6, 'ops2'),
	(12320008, 21, 1, 'ops3'),
	(12320008, 21, 2, 'ops4'),
	(12320008, 21, 3, 'ops1'),
	(12320008, 21, 4, 'ops5'),
	(12320008, 21, 5, 'ops3'),
	(12320008, 21, 6, 'ops2'),
	(12320009, 22, 1, 'ops2'),
	(12320009, 22, 2, 'ops3'),
	(12320009, 22, 3, 'ops4'),
	(12320009, 22, 4, 'ops5'),
	(12320009, 22, 5, 'ops2'),
	(12320009, 22, 6, 'ops1'),
	(12320020, 22, 1, 'ops2'),
	(12320020, 22, 2, 'ops3'),
	(12320020, 22, 3, 'ops5'),
	(12320020, 22, 4, 'ops1'),
	(12320020, 22, 5, 'ops3'),
	(12320020, 22, 6, 'ops4'),
	(12320019, 21, 1, 'ops2'),
	(12320019, 21, 2, 'ops3'),
	(12320019, 21, 3, 'ops4'),
	(12320019, 21, 4, 'ops5'),
	(12320019, 21, 5, 'ops1'),
	(12320019, 21, 6, 'ops3'),
	(12320019, 23, 1, 'ops3'),
	(12320019, 23, 2, 'ops1'),
	(12320019, 23, 3, 'ops3'),
	(12320016, 23, 1, 'ops2'),
	(12320016, 23, 2, 'ops3'),
	(12320016, 23, 3, 'ops1'),
	(12320016, 22, 1, 'ops2'),
	(12320016, 22, 2, 'ops4'),
	(12320016, 22, 3, 'ops1'),
	(12320016, 22, 4, 'ops4'),
	(12320016, 22, 5, 'ops3'),
	(12320016, 22, 6, 'ops4'),
	(12320013, 21, 1, 'ops2'),
	(12320013, 21, 2, 'ops1'),
	(12320013, 21, 3, 'ops3'),
	(12320013, 21, 4, 'ops4'),
	(12320013, 21, 5, 'ops5'),
	(12320013, 21, 6, 'ops2'),
	(12320013, 22, 1, 'ops2'),
	(12320013, 22, 2, 'ops4'),
	(12320013, 22, 3, 'ops1'),
	(12320013, 22, 4, 'ops5'),
	(12320013, 22, 5, 'ops4'),
	(12320013, 22, 6, 'ops4'),
	(12320012, 22, 1, 'ops2'),
	(12320012, 22, 2, 'ops4'),
	(12320012, 22, 3, 'ops1'),
	(12320012, 22, 4, 'ops4'),
	(12320012, 22, 5, 'ops3'),
	(12320012, 22, 6, 'ops4'),
	(12320012, 23, 1, 'ops3'),
	(12320012, 23, 2, 'ops2'),
	(12320012, 23, 3, 'ops1'),
	(12320014, 22, 1, 'ops2'),
	(12320014, 22, 2, 'ops3'),
	(12320014, 22, 3, 'ops4'),
	(12320014, 22, 4, 'ops5'),
	(12320014, 22, 5, 'ops1'),
	(12320014, 22, 6, 'ops2'),
	(12320014, 23, 1, 'ops2'),
	(12320014, 23, 2, 'ops3'),
	(12320014, 23, 3, 'ops3'),
	(12320014, 21, 1, 'ops2'),
	(12320014, 21, 2, 'ops3'),
	(12320014, 21, 3, 'ops1'),
	(12320014, 21, 4, 'ops5'),
	(12320014, 21, 5, 'ops3'),
	(12320014, 21, 6, 'ops3'),
	(12320012, 21, 1, 'ops1'),
	(12320012, 21, 2, 'ops2'),
	(12320012, 21, 3, 'ops1'),
	(12320012, 21, 4, 'ops3'),
	(12320012, 21, 5, 'ops2'),
	(12320012, 21, 6, 'ops1'),
	(12320017, 22, 1, 'ops2'),
	(12320017, 22, 2, 'ops3'),
	(12320017, 22, 3, 'ops4'),
	(12320017, 22, 4, 'ops5'),
	(12320017, 22, 5, 'ops1'),
	(12320017, 22, 6, 'ops3'),
	(12320017, 23, 1, 'ops2'),
	(12320017, 23, 2, 'ops4'),
	(12320017, 23, 3, 'ops1');

-- Dumping structure for table sql12658745.student
CREATE TABLE IF NOT EXISTS `student` (
  `std_name` varchar(255) DEFAULT NULL,
  `std_year` varchar(10) DEFAULT NULL,
  `std_rollno` int(11) DEFAULT NULL,
  `std_prn` int(11) NOT NULL AUTO_INCREMENT,
  `branch_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`std_prn`),
  KEY `branch_id` (`branch_id`),
  CONSTRAINT `student_ibfk_2` FOREIGN KEY (`std_prn`) REFERENCES `multiuserlogin` (`ID`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `student_ibfk_1` FOREIGN KEY (`branch_id`) REFERENCES `branches` (`branch_id`)
) ENGINE=InnoDB AUTO_INCREMENT=12320094 DEFAULT CHARSET=latin1;

-- Dumping data for table sql12658745.student: ~20 rows (approximately)
DELETE FROM `student`;
INSERT INTO `student` (`std_name`, `std_year`, `std_rollno`, `std_prn`, `branch_id`) VALUES
	('Neha Sharma', '1st', 1, 12320001, 12),
	('Rohit Singh', '2nd', 52, 12320002, 6),
	('Pooja Desai', '4th', 4, 12320003, 11),
	('Arjun Mehta', '1st', 46, 12320004, 10),
	('Anika Verma', '3rd', 7, 12320005, 7),
	('Sameer Choudhary', '2nd', 2, 12320006, 9),
	('Riya Kumar', '1st', 12, 12320007, 7),
	('Vinit Tiwari', '2nd', 80, 12320008, 9),
	('Sneha Patel', '3rd', 14, 12320009, 11),
	('Sartahk Jadhav', '4th', 7, 12320010, 10),
	('Vasudha Pathak', '2nd', 4, 12320011, 6),
	('Om Badar', '1st', 1, 12320012, 8),
	('Akash Kapse', '3rd', 36, 12320013, 12),
	('Diksha Nichat', '2nd', 81, 12320014, 12),
	('Prutha Pawade', '2nd', 82, 12320015, 6),
	('Sakshi Patharkar', '3rd', 5, 12320016, 7),
	('Lakhan Kariya', '4th', 5, 12320017, 7),
	('Pratik Dhame', '3rd', 23, 12320018, 11),
	('Soham Pande', '1st', 69, 12320019, 8),
	('Tejaswani Waghmare', '4th', 9, 12320020, 10);

-- Dumping structure for view sql12658745.FacultyList
-- Removing temporary table and create final VIEW structure
DROP TABLE IF EXISTS `FacultyList`;
CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `FacultyList` AS select `f`.`faculty_id` AS `faculty_id`,`f`.`faculty_name` AS `faculty_name`,`f`.`email` AS `email`,`b`.`branch_name` AS `branch_name`,`m`.`Password` AS `Password` from ((`faculty` `f` join `branches` `b` on((`f`.`branch_id` = `b`.`branch_id`))) join `multiuserlogin` `m` on((`f`.`faculty_id` = `m`.`ID`)));

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;

/*
PART 1:
1.	API1(candidate, timestamp, precinct)
*/
DELIMITER $$
DROP PROCEDURE IF EXISTS API1 $$
CREATE PROCEDURE API1(IN C VARCHAR(50), IN T TEXT, IN P TEXT)
BEGIN
	DECLARE MIN_TIMESTAMP TEXT;
	Select Min(timestamp) INTO MIN_TIMESTAMP From Penna;
	IF(P not IN (Select distinct precinct From Penna)) THEN
    		Select 'Unknown Precinct' as Error;
    	ELSEIF(UPPER(C) NOT IN('TRUMP', 'BIDEN')) THEN
    		Select 'Wrong Candidate' as Error;
    	ELSEIF T<MIN_TIMESTAMP THEN
		SELECT 0 as 'Election Not Started';
	ELSE
		Select MAX(timestamp) INTO T From PENNA p WHERE p.TIMESTAMP<=T;
		IF C = 'Trump' THEN
			SELECT p.Trump FROM Penna p WHERE  p.precinct = P AND p.TIMESTAMP = T;
		ELSEIF C = 'Biden' THEN
			SELECT p.Biden FROM PENNA p WHERE p.PRECINCT = P AND p.TIMESTAMP = T;
		END IF;
	END IF;
END $$
DELIMITER ;
CALL API1('Biden', '2020-11-04 09:06:53', 'Allegheny Township Voting Precinct');

/*
2.	API2(date)
*/
DELIMITER $$
	DROP PROCEDURE IF EXISTS API2 $$
	CREATE PROCEDURE API2(IN D TEXT)
    BEGIN
    	DECLARE MIN_TIMESTAMP TEXT;
    	DECLARE MAX_TIMESTAMP TEXT;
    	SELECT Min(Timestamp) INTO MIN_TIMESTAMP From Penna Where Timestamp Like '%-%-%' ;
    	SELECT Max(Timestamp) INTO MAX_TIMESTAMP From Penna;
    	IF (D not REGEXP '^[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]$') THEN
    		SELECT 'INVALID DATE FORMAT';
    	ELSE
    		IF D>MAX_TIMESTAMP THEN
    			SET D = MAX_TIMESTAMP;
    		ELSEIF D>MIN_TIMESTAMP THEN
    			SET D = (Select Max(p2.timestamp) From Penna p2 Where p2.timestamp Like concat(D,'%'));
    		END IF;
    		IF D<MIN_TIMESTAMP THEN
    			Select 'Election Not Started' as Current_Winner;
    		ELSE
    			Select IF(sum(Biden)>sum(Trump),concat('Biden = ',sum(biden),' votes'),concat('Trump = ',sum(trump), ' votes')) as Current_Winner From penna where timestamp = D;
    		END IF;
END IF;
END $$
DELIMITER ;
CALL API2('2020-11-06');

/*
3.	API3(CANDIDATE)
*/
DELIMITER $$
	DROP PROCEDURE IF EXISTS API3 $$
	CREATE PROCEDURE API3(IN C TEXT)
    BEGIN
    	IF(UPPER(C) NOT IN('TRUMP', 'BIDEN')) THEN
		Select 'Wrong Candidate' as Error;
    	ELSE
		IF(C='Biden') THEN
			SELECT Precinct FROM PENNA WHERE biden>trump AND TIMESTAMP = (select MAX(Timestamp) From Penna) ORDER BY totalvotes DESC LIMIT 10; 
		ELSEIF(C='Trump') THEN
			SELECT Precinct FROM PENNA WHERE biden<trump AND TIMESTAMP = (select MAX(Timestamp) From Penna) ORDER BY totalvotes DESC LIMIT 10; 
		END IF;
	END IF;
    END $$
    DELIMITER ;
    CALL API3('Biden');

/*
4.	API4(PRECINCT)
*/
DELIMITER $$
	DROP PROCEDURE IF EXISTS API4 $$
	CREATE PROCEDURE API4(IN P TEXT)
    BEGIN
  	IF(P not IN (Select distinct precinct From Penna)) THEN
    		Select 'Unknown Precinct' as Error;
	ELSE
		SELECT IF(trump>biden,'Trump','Biden') as Winner, IF(trump>Biden,(trump/totalvotes)*100,(biden/totalvotes)*100) as WinByPercentange From Penna Where precinct = P and timestamp = (select MAX(Timestamp) From Penna);
    	END IF;
    END $$
    DELIMITER ;
    CALL API4('New Hanover 1');

/*
5.	API5(STRING)
*/
DELIMITER $$
	DROP PROCEDURE IF EXISTS API5 $$
CREATE PROCEDURE `API5`(IN S TEXT)
BEGIN
	IF(NOT EXISTS(Select distinct Precinct From Penna where Locate(S,Precinct))) THEN
			SELECT Concat('No Precinct Includes String ',S) as Error;
	ELSE
		SELECT IF(SUM(trump)>sum(biden),'Trump','Biden') as Winner, IF(SUM(trump)>sum(biden),sum(Trump),sum(biden)) as votes From Penna Where Locate(S,precinct) and timestamp =  (select MAX(Timestamp) From Penna);
	END IF;
END $$
DELIMITER ;
CALL API5('Township');

/*
PART 2:
1.	newPenna()
*/
DELIMITER $$
	DROP PROCEDURE IF EXISTS newPenna $$
	CREATE PROCEDURE newPenna()
    BEGIN
    DECLARE var_count INT Default 0;
    DECLARE var_end_count INT Default 0;
    DECLARE I INT;
    DECLARE T TEXT;
    DECLARE S TEXT;
    DECLARE L TEXT;
    DECLARE P TEXT;
    DECLARE G TEXT;
    DECLARE TV INT;
    DECLARE B INT;
    DECLARE TR INT;
    DECLARE F TEXT;
    DECLARE cur CURSOR FOR Select ID,timestamp,state,locality,precinct,geo,totalvotes,Biden,Trump,filestamp From Penna;
    DROP TABLE IF EXISTS newPenna;
	create table newPenna(
	ID INT,
      	Timestamp TEXT,
       	state TEXT,
       	locality TEXT,
       	precinct TEXT,
       	geo TEXT,
       	totalvotes INT,
       	Biden INT,
	Trump INT,
       	filestamp TEXT
	);
SET var_count = 0;
SELECT count(*) into var_end_count FROM Penna;
	OPEN cur;
	WHILE var_count < var_end_count DO
	FETCH cur INTO I,T,S,L,P,G,TV,B,TR,F;
		INSERT INTO newPenna(ID,Timestamp,state,locality,precinct,geo,totalvotes,Biden,Trump,filestamp)(Select I,T,S,L,P,G,TV-t1.totalvotes,B-t1.Biden,TR-t1.Trump,F From Penna t1 where t1.precinct = P and t1.timestamp = (Select max(t3.timestamp) From Penna t3 Where t3.timestamp<T and t3.precinct=P));
        set var_count = var_count + 1;
END WHILE;
CLOSE cur;
END $$
DELIMITER ;
CALL newPenna();

/*
2.	switch()
*/
DELIMITER $$
	DROP PROCEDURE IF EXISTS Switch $$
	CREATE PROCEDURE Switch()
BEGIN
	SELECT p2.precinct,min(p2.timestamp) as timestamp,IF(Trump<Biden,'Trump','Biden') as fromCandidate, IF(Trump>Biden,'Trump','Biden') as toCandidate From Penna p2 Where IF(Trump<Biden,Trump,Biden)<IF(Trump>Biden,Trump,Biden) and not exists(Select p1.timestamp From Penna p1 Where p1.Precinct = p2.precinct and IF(p2.Trump<p2.Biden,Trump,Biden)>IF(p2.Trump>p2.Biden,Trump,Biden) and p1.timestamp>p2.timestamp) HAVING min(p2.timestamp)>(DATE_SUB((Select max(timestamp) From Penna), Interval 1 DAY));
END $$
DELIMITER ;
CALL switch();

OR
ANOTHER APPROACH: -

DELIMITER $$
	DROP PROCEDURE IF EXISTS Switch $$
	CREATE PROCEDURE Switch()
    BEGIN
    DECLARE MAX_TIMESTAMP TEXT;
    DECLARE P TEXT;
    DECLARE winner TEXT;
    DECLARE loser TEXT;
    DECLARE var_count INT DEFAULT 0;
    DECLARE var_end_count INT DEFAULT 0;
    DECLARE cur CURSOR FOR SELECT Precinct, IF(trump>Biden,'Trump','Biden'), IF(trump<Biden,'Trump','Biden') From Penna Where timestamp = (SELECT Max(Timestamp) From Penna);
    SELECT Max(Timestamp) INTO MAX_TIMESTAMP From Penna;
    DROP TABLE IF EXISTS `switch`;
	create table `switch`(
	   precinct TEXT,
	   timestamp TEXT,
     	  fromCandidate TEXT,
	  toCandidate TEXT
        );
SET var_count = 0;
    Select count(Precinct) INTO var_end_count From Penna  Where timestamp = MAX_TIMESTAMP;
	OPEN cur;
    While var_count < var_end_count DO
    Fetch cur INTO P,winner,loser;
		Insert into switch(precinct,timestamp,fromCandidate,toCandidate)(SELECT p2.precinct,min(p2.timestamp),loser as fromCandidate, winner as toCandidate From Penna p2 Where Precinct = P AND if(loser='Biden',Biden,Trump)<If(winner='Biden',Biden,Trump) and not exists(Select p1.timestamp From Penna p1 Where p1.Precinct = P and if(loser='Biden',Biden,Trump)>If(winner='Biden',Biden,Trump) and p1.timestamp>p2.timestamp) HAVING min(p2.timestamp)>(DATE_SUB(MAX_TIMESTAMP, Interval 1 DAY)));
		Set var_count = var_count+1;
	END WHILE;
    CLOSE cur;
    END $$
	DELIMITER ;
	CALL switch();
    Select * From switch;

/*
Part 3: 
1.	check3A() – The sum of votes for Trump and Biden cannot be larger than totalvotes
*/
DELIMITER $$
DROP PROCEDURE IF EXISTS check3A $$
CREATE PROCEDURE check3A()
BEGIN
		Select IF(Not Exists(Select timestamp,precinct From Penna Where Biden+Trump>totalvotes),'TRUE','FALSE') as Condition_3A_Fulfilled;
END $$
DELIMITER ;
CALL check3A();

/*
2.	check3B() – There cannot be any tuples with timestamps later than Nov 11 and earlier than Nov 3
*/
DELIMITER $$
	DROP PROCEDURE IF EXISTS check3B $$
	CREATE PROCEDURE check3B()
 BEGIN
		Select IF(Not Exists(Select timestamp From Penna Where timestamp>2020-11-11 and timestamp<2020-11-03),'TRUE','FALSE') as Condition_3B_Fulfilled;
END $$
DELIMITER ;
CALL check3B();

/*
3.	check3C() – Totalvotes for any precinct and at any timestamp T > 2020-11-05 00:00:00, will be larger or equal to totalvotes  at T’<T where T’>2020-11-05 00:00:00 for that precinct.
*/
DELIMITER $$
	DROP PROCEDURE IF EXISTS check3C $$
	CREATE PROCEDURE check3C()
BEGIN
		Select IF(Not Exists(Select p2.timestamp From Penna p1, Penna p2 Where p1.timestamp>'2020-11-05 00:00:00' and p1.timestamp<'2020-11-06 00:00:00' and p2.timestamp<p1.timestamp and p2.timestamp>'2020-11-05 00:00:00' and p2.timestamp<'2020-11-06 00:00:00' and p2.totalvotes>p1.totalvotes and p1.precinct=p2.precinct),'TRUE', 'FALSE') as Condition_3C_Fulfilled;
END $$
DELIMITER ;
CALL check3C();

/*
PART 4:
1.	INSERT, UPDATE, DELETE TRIGGERS
-- >	UPDATE TRIGGER
*/
DELIMITER $$
CREATE TRIGGER UPDATE_ON_PENNA 
AFTER UPDATE ON PENNA
FOR EACH ROW
BEGIN
Insert INTO updated_tuples    Values(OLD.ID,OLD.Timestamp,OLD.State,OLD.Locality,OLD.precinct,OLD.geo,OLD.totalvotes,OLD.biden,OLD.trump,OLD.filestamp);
END $$
DELIMITER ;
-- >	INSERT TRIGGER
DELIMITER $$
CREATE TRIGGER INSERT_AT_PENNA 
AFTER INSERT ON PENNA
FOR EACH ROW
BEGIN
	Insert INTO inserted_tuples
Values(NEW.ID,NEW.Timestamp,NEW.State,NEW.Locality,NEW.precinct,NEW.geo,NEW.totalvotes,NEW.biden,NEW.trump,NEW.filestamp);
END $$
DELIMITER ;
-- >	DELETE TRIGGER
DELIMITER $$
CREATE TRIGGER DELETE_FROM_PENNA 
AFTER DELETE ON PENNA
FOR EACH ROW
BEGIN
Insert INTO deleted_tuples Values(OLD.ID,OLD.Timestamp,OLD.State,OLD.Locality,OLD.precinct,OLD.geo,OLD.totalvotes,OLD.biden,OLD.trump,OLD.filestamp);
END $$
DELIMITER ;

/*
2.	MoveVotes(Precinct, Timestamp, Candidate, Number_of_Moved_Votes)
*/
DELIMITER $$
DROP PROCEDURE IF EXISTS MoveVotes $$
CREATE PROCEDURE MoveVotes(IN P TEXT,IN T TEXT,IN C TEXT,IN Num_Votes INT)
BEGIN
IF(P not IN (Select distinct precinct From Penna)) THEN
    		Select 'Unknown Precinct';
    	ELSEIF(T not IN (Select distinct timestamp From Penna)) THEN
    		Select 'Unknown Timestamp';
    	ELSEIF(UPPER(C) NOT IN('TRUMP', 'BIDEN')) THEN
   		 Select 'Wrong Candidate';
    	ELSEIF(Num_Votes<0) THEN
    		Select 'Invalid Votes Value';
    	ELSEIF(Num_Votes>(Select IF(C='Trump',Trump,Biden) From Penna Where timestamp=T and precinct=P)) THEN
    		Select 'Not Enough Votes';
    ELSE
	IF C='TRUMP' THEN
		UPDATE PENNA
        		SET Trump = Trump-Num_Votes, Biden = Biden+Num_Votes WHERE Timestamp >= T and Precinct = P;
	ELSEIF C='BIDEN' THEN
		UPDATE PENNA
        		SET Biden = Biden-Num_Votes, Trump = Trump+Num_Votes WHERE Timestamp >= T and Precinct = P;
	END IF;  
    END IF;
END $$
DELIMITER ;
CALL MoveVotes('HANOVER','2020-11-11 03:16:00','BIDEN',39);
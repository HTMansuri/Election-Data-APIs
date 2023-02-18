# Test cases for API1
CALL API1('Biden', '2020-11-04 09:06:53', 'Allegheny Township Voting Precinct');
CALL API1('BidenE', '2020-11-04 09:06:53', 'Allegheny Township Voting Precinct');
CALL API1('Biden', '2020-11-04 09:06:54', 'Allegheny Township Voting Precinct');
CALL API1('Biden', '2020-11-04 09:06:52', 'AlleghenI Township Voting Precinct');
Select min(timestamp) From Penna;
CALL API1('Biden', '2020-11-03 19:39:28', 'Allegheny Township Voting Precinct');
Select max(timestamp) From Penna;
CALL API1('Biden', '2020-11-11 21:50:51', 'Allegheny Township Voting Precinct');

# Test cases for API2
CALL API2('2020-11-06');
CALL API2('2020-11-6');
CALL API2('2020-11-O6');
Select min(timestamp) From Penna;
CALL API2('2020-11-03');
Select max(timestamp) From Penna;
CALL API2('2020-11-11');

# Test cases for API3
CALL API3('Biden');
CALL API3('Trump');
CALL API3('Bidon');

# Test cases for API4
CALL API4('New Hanover 1');
CALL API4('New Hangover 1');

# Test cases for API5
CALL API5('Township');
CALL API5('Townsheep');

# Update Trigger
Select * from Penna;
Update Penna
Set state='NJ' where timestamp='2020-11-04 03:58:36' and precinct='Adams Township - Dunlo Voting Precinct';
Select * from Penna where timestamp='2020-11-04 03:58:36' and precinct='Adams Township - Dunlo Voting Precinct';
Select * From updated_tuples
Update Penna
set totalvotes=trump+biden where timestamp='2020-11-11 21:50:46';
Set trump=2*trump where timestamp='2020-11-11 21:50:46';
Select sum(Trump),sum(Biden) from Penna where timestamp=(Select max(timestamp) From Penna);
Select * From updated_tuples

# Insert Trigger
Insert INTO Penna
Values('3111','2020-11-12 00:00:05','PA','Cambria','Adams Township - Dunlo Voting Precinct','42021-ADAMS TWP DUNLO',334,73,259,'NOVEMBER_12_2020_000005.json');
Select * From Penna where timestamp = '2020-11-12 00:00:05';
Select * From inserted_tuples
Insert INTO Penna
Values('3115','2020-11-12 00:12:05','PA','Cambria','Adams Township Precinct','42021-ADAMS TWP',338,78,260,'NOVEMBER_12_2020_001205.json');
Select * From Penna where timestamp = '2020-11-12 00:12:05';
Select * From inserted_tuples

# Delete Trigger
Delete From Penna where timestamp = '2020-11-12 00:12:05';
Select * From deleted_tuples
Delete From Penna where timestamp = '2020-11-12 00:00:05';
Select * From deleted_tuples
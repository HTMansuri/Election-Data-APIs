# Election-Data-APIs
 Description: API Calls to get results for some Key Questions/Functions concerning the Election Data
#
 Features:

- Powering simple interface to Penna table to get results for key questions/functions.
- API1(candidate, timestamp, precinct) - Given a candidate C, timestamp T and precinct P, returns: number of votes candidate C  have at T or largest timestamp T’ smaller than T, in case T does not appear in Penna. 
- API2(date) - Given a date, returns the candidate who had the most votes at the last timestamp for this date as well as how many votes he got.
- API3(candidate) - Given a candidate, returns top 10 precincts that this candidate won. Orders precincts by the attribute: totalvotes, and list TOP 10 in descending order of totalvotes.
- API4(precinct) - Given a precinct, Shows who won this precinct (Trump or Biden) as well as what percentage of total votes went to the winner.
- API5(string) - Given a string s of characters, it determines who won more votes in all precincts whose names contain this string s and how many votes did they get in total.
- newPenna(): This stored procedure creates a table newPenna, showing for each precinct how many votes were added to totalvotes, Trump, Biden between timestamp T and the last timestamp directly preceding T.
- Switch(): This stored procedure returns list of precincts, which have switched their winner from one candidate to another in last 24 hours of vote collection (i.e 24 hours before the last Timestamp data was collected) and that candidate was the ultimate winner of this precinct.
- Checks for the accuracy of data using stored procedures that check if the following patterns were enforced in the database:
   - The sum of votes for Trump and Biden cannot be larger than totalvotes.
   - There cannot be any tuples with timestamps later than Nov 11 and earlier than Nov3.
   - The total votes of any precinct should not decrease with increasing timestamps within the day of 2020-11-05.
- Triggers and Update driven Stored Procedures:
  - Created three tables Updated_Tuples, Inserted_Tuples and Deleted_Tuples, which have same schema as Penna
  - Update Trigger: stores any tuples which were updated (stores them as they were before the update) into the Updated_Tuples table.
  - Insert Trigger: stores any tuples which were inserted into the Inserted_Tuples table.
  - Delete Trigger: stores any tuples which were deleted into the Deleted_Tuples table.
- MoveVotes(Precinct, Timestamp, Candidate, Number_of_Moved_Votes): moves the Number_of_Moved_Votes from Given Candidate to another candidate (there are only two) and do it not just for the given Timestamp but also for all T>Timestamp, that is all future timestamps in the given precinct.
- Handle Logical and Input Formatting Errors for each of the functions.
#
 Technical Skills Implemented:
 
- Writing Efficient and Accurate SQL Queries.
- Creating Stored Procedures and Triggers.
- Using various SQL Functions to get the result in the most optimized way possible.
- Handling Logical and Input Formatting Errors.


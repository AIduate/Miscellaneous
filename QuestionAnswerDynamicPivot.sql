/****************************************************************************************
This is was something I had to write to gather some features for a machine learning model
where the questions were part of an application and checked with a Y or N and I thought
it was a fun task to share on this repo.
There were a lot more questions than the 4 examples I created below.
Afterwards there are some nulls where perhaps questions did not apply to certain items 
that do have to be handled before feeding into an ml model.
*****************************************************************************************/

DROP TABLE IF EXISTS #Questions
DROP TABLE IF EXISTS #Answers

DECLARE @SqlStatement NVARCHAR(MAX)
DECLARE @ListToPivot NVARCHAR(MAX)

CREATE TABLE
#Questions
(
ID INT,
Question VARCHAR(MAX)
)

INSERT INTO #Questions
VALUES(1, 'Is this a test?')
,(2, 'Is this a test2?')
,(3, 'Is this a test3?')
,(4, 'Is this a test4?')

CREATE TABLE
#Answers
(
ID INT,
Item_ID INT,
Question_ID INT,
Answer NVARCHAR(1)
)

INSERT INTO #Answers
VALUES(1, 1, 1, 'Y')
,(2, 1, 2, 'N')
,(3, 1, 4, 'Y')
,(4, 2, 1, 'N')
,(5, 2, 2, 'N')
,(6, 2, 3, 'N')
,(7, 2, 4, 'N')
,(8, 3, 1, 'Y')
,(9, 3, 3, 'Y')
,(10, 4, 1, 'Y')

SELECT @ListToPivot =
STUFF((SELECT DISTINCT ',' + QUOTENAME(Question)
            FROM #Questions WITH (NOLOCK)
            FOR XML PATH(''), TYPE
            ).value('.', 'NVARCHAR(MAX)')
        ,1,1,'')

SET @SqlStatement = N'

SELECT * FROM
(
SELECT
E1.Item_ID
,CAST(REPLACE(REPLACE(E1.Answer, ''Y'', 1), ''N'', 0) AS INT) QuestionAnswer
,E2.Question
FROM
#Answers AS E1
INNER JOIN #Questions AS E2 WITH (NOLOCK)
ON E1.Question_ID = E2.ID) AS Questions
PIVOT (
  SUM(QuestionAnswer)
  FOR Question
  IN (' + @ListToPivot + '
  )
) AS PivotTable';

EXECUTE sp_executesql @SqlStatement

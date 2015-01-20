-- These are the optional post processing tasks which may be performed.

-- UserTagQA TABLE
DROP TABLE IF EXISTS UserTagQA;
CREATE TABLE UserTagQA (
    UserId      int,
    TagId       int,
    Questions   int,
    Answers     int,
    PRIMARY KEY (UserId, TagId)
);
INSERT INTO UserTagQA
  ( SELECT P.ownerUserId AS UserId,
           PT.tagId      AS TagId,
           sum(CASE P.PostTypeId WHEN 1 THEN 1 ELSE 0 END) AS Questions,
           sum(CASE P.PostTypeId WHEN 2 THEN 1 ELSE 0 END) AS Answers
    FROM Posts P JOIN PostTags PT ON PT.PostId = P.Id
    WHERE P.OwnerUserId IS NOT NULL
    GROUP BY P.OwnerUserId, PT.TagId
  );
CREATE INDEX usertagqa_questions_idx ON UserTagQA USING btree (Questions)
    WITH (FILLFACTOR = 100);
CREATE INDEX usertagqa_answers_idx ON UserTagQA USING btree (Answers)
    WITH (FILLFACTOR = 100);


-- QuestionAnswer TABLE
DROP TABLE IF EXISTS QuestionAnswer;
CREATE TABLE QuestionAnswer (
    QuestionId int,
    AnswerId   int,
    PRIMARY KEY (QuestionId, AnswerId)
);
INSERT INTO QuestionAnswer
  ( SELECT P.ParentId as QuestionId, P.Id as AnswerId
    FROM Posts P WHERE P.PostTypeId = 2
  );

-- Questions VIEW
DROP VIEW IF EXISTS Questions;
CREATE VIEW Questions AS
    SELECT Id, AcceptedAnswerId, CreationDate, Score, ViewCount, OwnerUserId,
           LastEditorUserId, LastEditorDisplayName, LastEditDate,
           LastActivityDate, Title, Tags, AnswerCount, CommentCount,
           FavoriteCount, CommunityOwnedDate
    FROM Posts
    WHERE PostTypeId = 1;

-- Answers VIEW
DROP VIEW IF EXISTS Answers;
CREATE VIEW Answers AS
    SELECT Id, ParentId, CreationDate, Score, OwnerUserId, LastEditorUserId,
           LastEditorDisplayName, LastEditDate, LastActivityDate,
           CommentCount, CommunityOwnedDate
    FROM Posts
    WHERE PostTypeId = 2;


-- Composite indexes for Posts table
CREATE INDEX posts_id_post_type_id_idx ON Posts USING btree (Id, PostTypeId)
       WITH (FILLFACTOR = 100);
CREATE INDEX posts_id_parent_id_idx ON Posts USING btree (Id, ParentId)
       WITH (FILLFACTOR = 100);
CREATE INDEX posts_id_accepted_answers_id_idx ON Posts USING btree (Id, AcceptedAnswerId)
       WITH (FILLFACTOR = 100);
CREATE INDEX posts_owner_user_id_creation_date_idx ON Posts USING btree (OwnerUserId, CreationDate)
       WITH (FILLFACTOR = 100);
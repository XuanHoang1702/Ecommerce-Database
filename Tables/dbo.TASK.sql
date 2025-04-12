CREATE TABLE [dbo].[TASK] (
  [ID] [int] IDENTITY,
  [TASK_NAME] [nvarchar](255) NULL,
  [CREATED_AT] [datetime] NULL DEFAULT (getdate()),
  [UPDATED_AT] [datetime] NULL DEFAULT (getdate()),
  [TASK_STATUS] [nvarchar](20) NULL,
  [MAKED_ID] [nvarchar](20) NOT NULL,
  [CHECKER_ID] [nvarchar](20) NULL,
  PRIMARY KEY CLUSTERED ([ID])
)
ON [PRIMARY]
GO
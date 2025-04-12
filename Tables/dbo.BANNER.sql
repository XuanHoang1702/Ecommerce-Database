CREATE TABLE [dbo].[BANNER] (
  [ID] [int] IDENTITY,
  [NAME] [nvarchar](255) NULL,
  [IMAGE] [nvarchar](20) NULL,
  [STATUS] [nvarchar](10) NULL,
  [CREATED_AT] [datetime] NULL DEFAULT (getdate()),
  [UPDATED_AT] [datetime] NULL DEFAULT (getdate()),
  PRIMARY KEY CLUSTERED ([ID]),
  UNIQUE ([NAME]),
  CHECK ([STATUS]='INACTIVE' OR [STATUS]='ACTIVE')
)
ON [PRIMARY]
GO
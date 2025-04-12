CREATE TABLE [dbo].[MENU] (
  [ID] [int] IDENTITY,
  [MENU_NAME] [nvarchar](50) NULL,
  [MENU_LINK] [nvarchar](50) NULL,
  [PARENT_ID] [int] NULL,
  [MENU_STATUS] [nvarchar](10) NULL,
  [CREATED_AT] [datetime] NULL DEFAULT (getdate()),
  [UPDATED_AT] [datetime] NULL DEFAULT (getdate()),
  PRIMARY KEY CLUSTERED ([ID]),
  UNIQUE ([MENU_LINK]),
  UNIQUE ([MENU_NAME]),
  CHECK ([MENU_STATUS]='INACTIVE' OR [MENU_STATUS]='ACTIVE')
)
ON [PRIMARY]
GO
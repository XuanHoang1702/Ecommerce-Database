CREATE TABLE [dbo].[ORDERS] (
  [ID] [nvarchar](255) NOT NULL,
  [USER_ID] [nvarchar](255) NOT NULL,
  [ADDRESS_ID] [int] NOT NULL,
  [TOTAL_QUANTITY] [int] NOT NULL,
  [TOTAL_PRICE] [decimal](10, 2) NOT NULL,
  [NOTE] [nvarchar](max) NULL,
  [ORDER_STATUS] [nvarchar](15) NOT NULL,
  [CREATED_AT] [datetime] NULL DEFAULT (getdate()),
  [UPDATED_AT] [datetime] NULL,
  PRIMARY KEY CLUSTERED ([ID])
)
ON [PRIMARY]
TEXTIMAGE_ON [PRIMARY]
GO
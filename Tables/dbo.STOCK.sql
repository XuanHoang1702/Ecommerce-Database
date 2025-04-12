CREATE TABLE [dbo].[STOCK] (
  [ID] [int] IDENTITY,
  [PRODUCT_ID] [int] NOT NULL,
  [PRICE_ROOT] [decimal](10, 2) NOT NULL,
  [QUANTITY] [int] NOT NULL,
  [CREATED_AT] [datetime] NULL DEFAULT (getdate()),
  [UPDATED_AT] [datetime] NULL,
  PRIMARY KEY CLUSTERED ([ID])
)
ON [PRIMARY]
GO
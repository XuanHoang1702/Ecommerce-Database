SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[PRODUCT_IMAGE_ById]
	@p_PRODUCT_ID int 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	select *
	from 
	PRODUCT_IMAGE
	where PRODUCT_ID = @p_PRODUCT_ID
END
GO
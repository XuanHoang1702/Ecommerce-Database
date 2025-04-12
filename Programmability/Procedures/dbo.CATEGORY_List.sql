SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[CATEGORY_List]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT CATEGORY_ID, CATEGORY_NAME, CATEGORY_IMAGE, CATEGORY_STATUS
	FROM CATEGORIES
END
GO
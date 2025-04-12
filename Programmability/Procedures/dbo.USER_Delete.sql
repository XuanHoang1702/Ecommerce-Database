SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[USER_Delete] 
	@p_USER_ID nvarchar(20)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	delete from USERS where [USER_ID] = @p_USER_ID

	select N'Tài khoản đã được xóa thành công' as RESULT,
		   200 as CODE
END
GO
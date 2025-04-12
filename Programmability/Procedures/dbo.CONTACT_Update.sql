SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[CONTACT_Update] 
	@p_CONTACT_ID INT,
	@p_ADMIN_ID NVARCHAR(10),
	@p_CONTACT_STATUS NVARCHAR(10)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	BEGIN TRANSACTION
	declare @p_ROLE_RESULT nvarchar(10)
		exec [dbo].[CHECK_ROLE] @p_ADMIN_ID = @p_ADMIN_ID, @p_RESULT = @p_ROLE_RESULT output

		if @p_ROLE_RESULT != 'OK'
		begin
			rollback transaction
			select N'Không đủ quyền' as RESULT,
					403 as CODE
			return
		end

	UPDATE CONTACT
	SET CONTACT_STATUS = @p_CONTACT_STATUS,
		UPDATED_AT = GETDATE()
	WHERE ID = @p_CONTACT_ID;

	-- Kiểm tra kết quả cập nhật
	IF @@ROWCOUNT = 1
	BEGIN
		COMMIT TRANSACTION;
		select  N'Cập nhật thành công!' as RESULT,
				200 as CODE
	END
	ELSE
	BEGIN
		ROLLBACK TRANSACTION;
		select ERROR_MESSAGE() as RESULT,
				ERROR_NUMBER() as CODE
	END
END
GO
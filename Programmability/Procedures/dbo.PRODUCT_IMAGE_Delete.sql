﻿SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[PRODUCT_IMAGE_Delete]
	@p_ADMIN_ID nvarchar(20),
	@p_IMAGE_ID int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    begin transaction
	begin try

		declare @p_ROLE_RESULT nvarchar(10)
		exec [dbo].[CHECK_ROLE] @p_ADMIN_ID = @p_ADMIN_ID, @p_RESULT = @p_ROLE_RESULT output

		IF @p_ROLE_RESULT <> 1
		begin
			rollback transaction
			select N'Không đủ quyền' as RESULT,
					403 as CODE
			return
		end

		if not exists (select 1 from PRODUCT_IMAGE where IMAGE_ID = @p_IMAGE_ID)
		begin
			rollback transaction
			select	 N'Không tồn tại ảnh' as RESULT,
					404 as CODE
			return
		end

		delete from PRODUCT_IMAGE where IMAGE_ID = @p_IMAGE_ID

		if @@ROWCOUNT <> 0
		begin
			commit transaction
			select N'Xóa ảnh thành công' as RESULT,
					200 as CODE
		end
	end try
	begin catch
		rollback transaction
		select  ERROR_MESSAGE() as RESULT,
				ERROR_NUMBER() as  CODE
		return
	end catch
END
GO
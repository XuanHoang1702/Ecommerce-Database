SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[DISCOUNT_Delete]
	@p_ADMIN_ID nvarchar(20),
	@p_DISCOUNT_ID int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	begin transaction
	begin try
		declare @p_PRODUCT_ID int

		declare @p_ROLE_RESULT nvarchar(10)
		exec [dbo].[CHECK_ROLE] @p_ADMIN_ID = @p_ADMIN_ID, @p_RESULT = @p_ROLE_RESULT output

		if @p_ROLE_RESULT != 'OK'
		begin
			rollback transaction
			select N'Không đủ quyền' as RESULT,
					403 as CODE
			return
		end

		if not exists (select 1 from DISCOUNT where DISCOUNT_ID = @p_DISCOUNT_ID)
		begin
			rollback transaction
			select N'Giảm giá không tồn tại' as RESULT,
					404 as CODE
			return
		end


		if exists (select 1 from ORDER_DETAILS where PRODUCT_ID in (select PRODUCT_ID from DISCOUNT where DISCOUNT_ID = @p_DISCOUNT_ID))
		begin
			rollback transaction
			select N'Không thể xóa ngay lúc này' as RESULT,
					409 as CODE
			return
		end

		delete from DISCOUNT where DISCOUNT_ID = @p_DISCOUNT_ID
		if @@ROWCOUNT <> 0
		begin
			commit transaction
			select 'Xóa thành công' as RESULT,
					200 as CODE
		end
	end try
	begin catch
		rollback transaction
		select error_message() as RESULT,
				error_number() as CODE

		return
	end catch
    
END
GO
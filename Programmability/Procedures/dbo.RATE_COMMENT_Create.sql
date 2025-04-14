SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[RATE_COMMENT_Create]
	@p_RATE_COMMENT_DATA nvarchar(max)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	begin transaction
	begin try
		declare	 @p_USER_ID nvarchar(50),
				 @p_PRODUCT_ID int,
				 @p_RATE int,
				 @p_COMMENT nvarchar(max)

		select	 @p_USER_ID = UserId,
				 @p_PRODUCT_ID = ProductId,
				 @p_RATE = Rate,
				 @p_COMMENT = Comment
		from openjson(@p_RATE_COMMENT_DATA)
		with(
			UserId nvarchar(50) '$.USER_ID',
			ProductId int '$.PRODUCT_ID',
			Rate int '$.RATE',
			Comment nvarchar(max) '$.COMMENT'
		)

		if not exists (select 1 from USERS where [USER_ID] = @p_USER_ID)
		begin
			rollback transaction
			select N'Bạn chưa đăng ký tài khoản' as RESULT,
					403 as CODE
			return
		end
		
		insert into RATE_COMMENT (RATE, COMMENT, PRODUCT_ID, USER_ID, CREATED_AT)
		values (@p_RATE, @p_COMMENT, @p_PRODUCT_ID, @p_USER_ID, getdate())

		if @@ROWCOUNT <> 0
		begin
			commit transaction
			select N'Đánh giá sản phẩm thành công' as RESULT,
					201 as CODE
		end

	end try
	begin catch
		rollback transaction
		select ERROR_MESSAGE() as RESULT,
				ERROR_NUMBER() as CODE
		return
	end catch
END
GO
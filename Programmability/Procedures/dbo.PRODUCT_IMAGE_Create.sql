SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[PRODUCT_IMAGE_Create]
	@p_PRODUCT_IMAGE_DATA nvarchar(max)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	begin transaction
	begin try
		declare	 @p_ADMIN_ID nvarchar(20),
				 @p_IMAGE_NAME nvarchar(20),
				 @p_PRODUCT_ID int,
				 @p_IMAGE_STATUS nvarchar(20)

		select	@p_ADMIN_ID = ADMIN_ID,
				@p_IMAGE_NAME = ImageName,
				@p_PRODUCT_ID = ProductId,
				@p_IMAGE_STATUS = ImageStatus
		from openjson(@p_PRODUCT_IMAGE_DATA)
		with(
			ADMIN_ID nvarchar(20) '$.ADMIN_ID',
			ImageName nvarchar(20) '$.IMAGE_NAME',
			ProductId int '$.PRODUCT_ID',
			ImageStatus nvarchar(10) '$.IMAGE_STATUS'
		)

		declare @p_ROLE_RESULT nvarchar(10)
		exec [dbo].[CHECK_ROLE] @p_ADMIN_ID = @p_ADMIN_ID, @p_RESULT = @p_ROLE_RESULT output

		IF @p_ROLE_RESULT <> 1
		begin
			rollback transaction
			select N'Không đủ quyền' as RESULT,
					403 as CODE
			return
		end

		if not exists (select 1 from PRODUCTS where PRODUCT_ID = @p_PRODUCT_ID)
		begin
			rollback transaction
			select N'Không tồn tại sản phẩm' as RESULT,
					404 as CODE
			return
		end

		insert into PRODUCT_IMAGE (IMAGE_NAME, PRODUCT_ID, IMAGE_STATUS, CREATE_AT, UPDATED_AT)
		values (@p_IMAGE_NAME, @p_PRODUCT_ID, @p_IMAGE_STATUS, getdate(), getdate())

		if @@ROWCOUNT <> 0
		begin 
			commit transaction
			select N'Thêm mới ảnh thành công' as RESLT,
					201 as CODE, 
					@p_IMAGE_NAME as IMAGE_NAME,
					@p_PRODUCT_ID as PRODUCT_ID,
					@p_IMAGE_STATUS as IMAGE_STATUS
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
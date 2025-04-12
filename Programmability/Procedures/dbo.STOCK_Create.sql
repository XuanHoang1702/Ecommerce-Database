SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[STOCK_Create] 
	@p_STOCK_DATA_JSON nvarchar(max)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	begin transaction
	begin try
		declare	 @p_ADMIN_ID nvarchar(20),
				 @p_PRODUCT_ID int,
				 @p_PRICE_ROOT decimal(10, 2),
				 @p_QUANTITY int

		select	 @p_ADMIN_ID = AdminId,
				 @p_PRODUCT_ID = ProductId,
				 @p_PRICE_ROOT = PriceRoot,
				 @p_QUANTITY = Quantity

		from openjson(@p_STOCK_DATA_JSON)
		with(
			AdminId nvarchar(20) '$.ADMIN_ID',
			ProductId int '$.PRODUCT_ID',
			PriceRoot decimal(10, 2) '$.PRICE_ROOT',
			Quantity int '$.QUANTITY'
		)

		declare @p_ROLE_RESULT nvarchar(10)
		exec [dbo].[CHECK_ROLE] @p_ADMIN_ID = @p_ADMIN_ID, @p_RESULT = @p_ROLE_RESULT output

		if @p_ROLE_RESULT != 'OK'
		begin
			rollback transaction
			select N'Không đủ quyền' as RESULT,
					403 as CODE
			return
		end

		if not exists (select 1 from PRODUCTS where PRODUCT_ID = @p_PRODUCT_ID)
		begin 
			rollback transaction
			select	 N'Sản phẩm không tồn tại' as RESULT,
						404 as CODE
			return
		end

		if @p_PRICE_ROOT < 0 or @p_PRICE_ROOT = 0
		begin
			rollback transaction
			select	 N'Giá không hợp lệ' as RESULT,
					422 as CODE
			return
		end

		if @p_QUANTITY < 0 or @p_QUANTITY = 0
		begin
			rollback transaction
			select N'Số lượng không hợp lệ' as RESULT,
					422 as CODE
		end

		insert into STOCK (PRODUCT_ID, PRICE_ROOT, QUANTITY)
		values (@p_PRODUCT_ID, @p_PRICE_ROOT, @p_QUANTITY)

		if @@ROWCOUNT <> 0
		begin
			commit transaction
			select *, N'Thêm mới sản phẩm vào kho thành công' as RESULT, 201 as CODE
			from STOCK
			where PRODUCT_ID = @p_PRODUCT_ID
		end
	end try
	begin catch
		rollback transaction
		select	ERROR_MESSAGE() as RESULT,
				ERROR_NUMBER() as CODE
		return
	end catch

END
GO
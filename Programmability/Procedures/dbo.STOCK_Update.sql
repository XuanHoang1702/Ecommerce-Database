SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[STOCK_Update] 
	@p_STOCK_DATA_JSON nvarchar(max)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	begin transaction
	begin try
		declare	@p_ADMIN_ID nvarchar(20),
				@p_STOCK_ID int,
				@p_PRODUCT_ID int, 
				@p_PRICE_ROOT decimal(10, 2),
				@p_QUANTITY int

		select  @p_ADMIN_ID = ADMIN_ID,
			    @p_STOCK_ID = StockId,
				@p_PRODUCT_ID = ProductId, 
				@p_PRICE_ROOT = PriceRoot,
				@p_QUANTITY = Quantity
		from openjson(@p_STOCK_DATA_JSON)
		with(
			ADMIN_ID nvarchar '$.ADMIN_ID',
			StockId int '$.STOCK_ID',
			ProductId int '$.PRODUCT_ID',
			PriceRoot decimal(10, 2) '$.PRICE_ROOT',
			Quantity int '$.QUANTITY'
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

		if @p_PRICE_ROOT = 0 or @p_PRICE_ROOT is null or @p_PRICE_ROOT < 0 
		begin
			rollback transaction
			select	N'Giá gốc không hợp lệ' as RESULT,
					422 as CODE
			return
		end

		if @p_QUANTITY = 0 or @p_QUANTITY is null or @p_QUANTITY < 0 
		begin
			rollback transaction
			select	N'Số lượng không hợp lệ' as RESULT,
					422 as CODE
			return
		end	

		update STOCK
		set  PRODUCT_ID = isnull(@p_PRODUCT_ID, PRODUCT_ID),
			 PRICE_ROOT = isnull(@p_PRICE_ROOT, PRICE_ROOT),
			 QUANTITY = isnull(@p_QUANTITY, QUANTITY),
			 UPDATED_AT = getdate()
		where ID = @p_STOCK_ID

		if @@ROWCOUNT <> 0
		begin
			commit transaction
			select N'Cập nhật kho thành công' as RESULT,
				200 as CDEO
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
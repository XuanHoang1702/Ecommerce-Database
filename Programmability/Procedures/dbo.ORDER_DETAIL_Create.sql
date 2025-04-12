SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[ORDER_DETAIL_Create]
	@p_ORDER_ID nvarchar(20),
	@p_ORDER_DETAIL_DATA_JSON nvarchar(max)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	begin transaction
	begin try
		
		if not exists (select 1 from ORDERS where ID = @p_ORDER_ID)
		begin
			rollback transaction
			select 
				'Mã đơn hàng không tồn tại' as RESULT,
				'400' as CODE
			return
		end

		if @p_ORDER_DETAIL_DATA_JSON IS NULL 
		begin
			rollback transaction
			select 'Dữ liệu không thể trống' as RESULT,
					'400' as CODE
			return
		end

		insert into ORDER_DETAILS (PRODUCT_ID, QUANTITY, PRODUCT_PRICE, SUBTOTAL, ORDER_ID)
		select
			json_value(value, '$.PRODUCT_ID'),
			json_value(value, '$.QUANTITY'),
			json_value(value, '$.PRODUCT_PRICE'),
			json_value(value, '$.SUBTOTAL'),
			@p_ORDER_ID

		from openjson(@p_ORDER_DETAIL_DATA_JSON)

		if @@ROWCOUNT <> 0
		begin
			commit transaction
			select	 'Thêm chi tiết đơn hàng thành công' as RESULT,
					  '201' as CODE
		end

	end try
	begin catch
		rollback transaction
		select ERROR_MESSAGE() AS RESULT
		return
	end catch
END
GO
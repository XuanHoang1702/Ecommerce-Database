SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[ORDER_Create] 
	@p_ORDER_DATA_JSON nvarchar(max)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	begin transaction
	begin try
		declare	 @p_USER_ID nvarchar(20),
				 @p_ADDRESS_ID int,
				 @p_TOTAL_QUANTITY int,
				 @p_TOTAL_PRICE decimal(10, 2),
				 @p_NOTE nvarchar(max),
				 @p_ORDER_STATUS nvarchar(20)

		select  @p_USER_ID = UserId,
				@p_ADDRESS_ID = AddressId,
				@p_TOTAL_QUANTITY = TotalQuantity,
				@p_TOTAL_PRICE = TotalPrice,
				@p_NOTE = Note,
				@p_ORDER_STATUS = OrderStatus
		from openjson(@p_ORDER_DATA_JSON)
		with(
			UserId nvarchar '$.USER_ID',
			AddressId int '$.ADDRESS_ID',
			TotalQuantity int '$.TOTAL_QUANTITY',
			TotalPrice decimal(10, 2) '$.TOTAL_QUANTITY',
			Note nvarchar(max) '$.NOTE',
			OrderStatus nvarchar(20) '$.ORDER_STATUS'
		)

		if not exists (select 1 from USERS where [USER_ID] = @p_USER_ID)
		begin
			rollback transaction
			select N'Người dùng chưa có tài khoản' as RESULT,
					404 as CODE
			return
		end

		if not exists (select 1 from ADDRESSES where ID = @p_ADDRESS_ID)
		begin
			rollback transaction
			select N'Chưa có địa chỉ nhận hàng' as RESULT,
					404 as CODE
			return
		end
		set @p_ORDER_STATUS = isnull(@p_ORDER_STATUS, 'PENDING')

		insert into ORDERS (USER_ID, ADDRESS_ID, TOTAL_QUANTITY, TOTAL_PRICE, NOTE, ORDER_STATUS, CREATED_AT, UPDATED_AT)
		values (@p_USER_ID, @p_ADDRESS_ID, @p_TOTAL_QUANTITY, @p_TOTAL_PRICE, @p_NOTE, @p_ORDER_STATUS, GETDATE(), GETDATE())

		if @@ROWCOUNT <> 0
		begin
			commit transaction
			select N'Tạo đơn hàng thành công' as RESULT,
				   201 as CODE
			return
		end

	end try
	begin catch
		rollback transaction
		select ERROR_MESSAGE() as RESULT,
			   ERROR_NUMBER() as CODE
	end catch
END
GO
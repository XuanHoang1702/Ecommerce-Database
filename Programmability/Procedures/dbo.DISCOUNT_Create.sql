SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[DISCOUNT_Create]
	@p_DISCOUNT_DATA_JSON nvarchar(max)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	begin transaction
	begin try
		declare	 @p_ADMIN_ID nvarchar(20),
				 @p_PRODUCT_ID int,
				 @p_DISCOUNT_PERCENT decimal(10, 2),
				 @p_START_DT datetime,
				 @p_END_DT datetime,
				 @p_DISCOUNT_STATUS nvarchar(10)

		select	 @p_ADMIN_ID = AdminId,
				 @p_PRODUCT_ID = ProductId,
				 @p_DISCOUNT_PERCENT = DiscountPercent,
				 @p_START_DT = StartDate,
				 @p_END_DT = EndDate
		from openjson(@p_DISCOUNT_DATA_JSON)
		with(
			AdminId nvarchar '$.ADMIN_ID',
			ProductId int '$.PRODUCT_ID',
			DiscountPercent decimal(10, 2) '$.DISCOUNT_PERCENT',
			StartDate datetime '$.START_DT',
			EndDate datetime '$.END_DT'
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
			select N'Sản phẩm không tồn tại' as RESULT,
					404 as CODE		
			return
		end

		if exists (select 1 from DISCOUNT where PRODUCT_ID = @p_PRODUCT_ID and END_DT > @p_START_DT)
		begin
			rollback transaction
			select N'Sản phẩm đang được giảm giá' as RESULT,
					409 as CODE
			return
		end

		insert into DISCOUNT (PRODUCT_ID, DISCOUNT_PERCENT, START_DT, END_DT, DISCOUNT_STATUS)
		values (@p_PRODUCT_ID, @p_DISCOUNT_PERCENT, @p_START_DT, @p_END_DT, @p_DISCOUNT_STATUS)

		if @@ROWCOUNT = 1
		begin
			commit transaction
			select  @p_PRODUCT_ID AS PRODUCT_ID,
					@p_DISCOUNT_PERCENT AS DISCOUNT_PERCENT,
					@p_START_DT AS START_DT,
					@p_END_DT AS END_DT,
					@p_DISCOUNT_STATUS AS DISCOUNT_STATUS,
					N'Tạo giảm giá thành công' as RESULT,
					201 as CODE
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
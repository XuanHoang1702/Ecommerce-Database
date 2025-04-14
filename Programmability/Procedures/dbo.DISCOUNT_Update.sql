SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[DISCOUNT_Update] 
	@p_DISCOUNT_DATA_JSON nvarchar(max)
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRANSACTION
	BEGIN TRY
		DECLARE @p_ADMIN_ID nvarchar(20),
				@p_DISCOUNT_ID int,
				@p_PRODUCT_ID int,
				@p_DISCOUNT_PERCENT decimal(10, 2),
				@p_START_DT datetime,
				@p_END_DT datetime,
				@p_DISCOUNT_STATUS nvarchar(10)

		IF ISJSON(@p_DISCOUNT_DATA_JSON) = 0
		BEGIN
			ROLLBACK TRANSACTION
			select N'Dữ liệu trống' as RESULT,
					422 as CODE
			RETURN
		END

		SELECT	@p_ADMIN_ID = ADMIN_ID,
				@p_DISCOUNT_ID = DiscountId,
				@p_PRODUCT_ID = ProductId,
				@p_DISCOUNT_PERCENT = DiscountPercent,
				@p_START_DT = StartDate,
				@p_END_DT = EndDate,
				@p_DISCOUNT_STATUS = DiscountStatus
		FROM OPENJSON(@p_DISCOUNT_DATA_JSON)
		WITH (
			ADMIN_ID nvarchar(20) '$.ADMIN_ID',
			DiscountId int '$.DISCOUNT_ID',
			ProductId int '$.PRODUCT_ID',
			DiscountPercent decimal(10, 2) '$.DISCOUNT_PERCENT',
			StartDate datetime '$.START_DT',
			EndDate datetime '$.END_DT',
			DiscountStatus nvarchar(10) '$.DISCOUNT_STATUS'
		)


        DECLARE @p_ROLE_RESULT int;
        EXEC [dbo].[CHECK_ROLE] @p_ADMIN_ID = @p_ADMIN_ID, @p_RESULT = @p_ROLE_RESULT OUTPUT;

        IF @p_ROLE_RESULT <> 1
        BEGIN
            ROLLBACK TRANSACTION;
            SELECT N'Không đủ quyền' AS RESULT, 403 AS CODE;
            RETURN;
        END

		IF NOT EXISTS (SELECT 1 FROM DISCOUNT WHERE DISCOUNT_ID = @p_DISCOUNT_ID)
		BEGIN
			ROLLBACK TRANSACTION
			select N'Mã giảm giá không tồn tại' as RESULT,
					404 as CODE
			RETURN
		END

		IF NOT EXISTS (SELECT 1 FROM PRODUCTS WHERE PRODUCT_ID = @p_PRODUCT_ID)
		BEGIN
			ROLLBACK TRANSACTION
			select N'Sản phẩm không tồn tại' as RESULT,
					404 as CODE
			RETURN
		END

		-- Cập nhật
		UPDATE DISCOUNT
		SET PRODUCT_ID = @p_PRODUCT_ID,
			DISCOUNT_PERCENT = @p_DISCOUNT_PERCENT,
			START_DT = @p_START_DT,
			END_DT = @p_END_DT,
			DISCOUNT_STATUS = @p_DISCOUNT_STATUS
		WHERE DISCOUNT_ID = @p_DISCOUNT_ID

		COMMIT TRANSACTION

		SELECT  @p_DISCOUNT_ID AS DISCOUNT_ID,
				@p_PRODUCT_ID AS PRODUCT_ID,
				@p_DISCOUNT_PERCENT AS DISCOUNT_PERCENT,
				@p_START_DT AS START_DT,
				@p_END_DT AS END_DT,
				@p_DISCOUNT_STATUS AS DISCOUNT_STATUS,
				N'Cập nhật giảm giá thành công' as RESULT,
				200 as CODE

	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
		select ERROR_MESSAGE() as RESULT,
				error_number() as CODE
		RETURN
	END CATCH
END
GO
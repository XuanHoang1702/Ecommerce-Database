SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[ADDRESS_Create]
    @p_ADDRESS_DATA_JSON NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRANSACTION;
    BEGIN TRY
        DECLARE  @p_USER_ID NVARCHAR(255),
                 @p_HOUSE_NUMBER NVARCHAR(255),
                 @p_STREET NVARCHAR(255),
                 @p_CITY NVARCHAR(255),
                 @p_POSTAL_CODE NVARCHAR(255),
                 @p_COUNTRY NVARCHAR(255),
                 @p_TYPE_ADDRESS NVARCHAR(255)

        -- Lấy dữ liệu từ JSON
        SELECT   @p_USER_ID = UserId,
                 @p_HOUSE_NUMBER = HouseNumber,
                 @p_STREET = Street,
                 @p_CITY = City,
                 @p_POSTAL_CODE = PostalCode,
                 @p_COUNTRY = Country,
                 @p_TYPE_ADDRESS = TypeAddress
        FROM OPENJSON(@p_ADDRESS_DATA_JSON)
        WITH (
                UserId NVARCHAR(255) '$.USER_ID',
                HouseNumber NVARCHAR(255) '$.HOUSE_NUMBER',
                Street NVARCHAR(255) '$.STREET',
                City NVARCHAR(255) '$.CITY',
                PostalCode NVARCHAR(255) '$.POSTAL_CODE',
                Country NVARCHAR(255) '$.COUNTRY',
                TypeAddress NVARCHAR(255) '$.TYPE_ADDRESS'
        );

        IF NOT EXISTS (SELECT 1 FROM USERS WHERE USER_ID = @p_USER_ID)
        BEGIN
            rollback transaction
			select	N'Người dùng không tồn tại' as RESULT,
					400 as CODE
			return 
        END

        INSERT INTO ADDRESSES (USER_ID, HOUSE_NUMBER, STREET, CITY, POSTAL_CODE, COUNTRY, TYPE_ADDRESS)
        VALUES (@p_USER_ID, @p_HOUSE_NUMBER, @p_STREET, @p_CITY, @p_POSTAL_CODE, @p_COUNTRY, @p_TYPE_ADDRESS);

        COMMIT TRANSACTION;
		SELECT HOUSE_NUMBER, STREET, CITY, POSTAL_CODE, COUNTRY, TYPE_ADDRESS, N'Thêm địa chỉ thành công' as RESULT, 201 as CODE
		FROM [dbo].[ADDRESSES]
		WHERE [USER_ID] = @p_USER_ID
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        select ERROR_MESSAGE() as RESULT,
			   ERROR_NUMBER() as CODE
		return
    END CATCH
END
GO
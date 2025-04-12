SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[ADDRESS_Up] 
    @p_ADDRESS_DATA_JSON NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRANSACTION;
    BEGIN TRY
        DECLARE @p_USER_ID NVARCHAR(255),
                @p_HOUSE_NUMBER NVARCHAR(255),
                @p_STREET NVARCHAR(255),
                @p_CITY NVARCHAR(255),
                @p_POSTAL_CODE NVARCHAR(255),
                @p_COUNTRY NVARCHAR(255),
                @p_TYPE_ADDRESS NVARCHAR(255)

        -- READ JSON
        SELECT  @p_USER_ID = UserId,
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

        -- CHECK USER_ID TỒN TẠI TRONG BẢNG ADDRESS
        IF NOT EXISTS (SELECT 1 FROM [dbo].[ADDRESSES] WHERE USER_ID = @p_USER_ID)
        BEGIN
            ROLLBACK TRANSACTION;
			select N'Người dùng không tồn tại hoặc không có địa chỉ' as RESULT,
					400 as CODE
            RETURN;
        END

        UPDATE [dbo].[ADDRESSES]
        SET HOUSE_NUMBER = @p_HOUSE_NUMBER,
            STREET = @p_STREET,
            CITY = @p_CITY,
            POSTAL_CODE = @p_POSTAL_CODE,
            COUNTRY = @p_COUNTRY,
            TYPE_ADDRESS = @p_TYPE_ADDRESS,
            UPDATED_AT = GETDATE()
        WHERE USER_ID = @p_USER_ID;

		if @@ROWCOUNT <> 0
		begin        
			COMMIT TRANSACTION;
			SELECT USER_ID, HOUSE_NUMBER, STREET, CITY, POSTAL_CODE, COUNTRY, TYPE_ADDRESS, N'Cập nhật thành công' as RESULT, 200 as CODE
			FROM [dbo].[ADDRESSES]
			WHERE USER_ID = @p_USER_ID;
		end 

    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        select ERROR_MESSAGE() as RESULT,
				ERROR_NUMBER() as CODE
		return
    END CATCH
END;
GO
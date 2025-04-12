SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[ORDER_DETAIL_Delete]
	@p_ORDER_ID nvarchar(20)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	begin transaction
	begin try

	
		delete from ORDER_DETAILS where ORDER_ID = @p_ORDER_ID
		if @@ROWCOUNT <> 0
		begin 
			commit transaction
			select 'Xóa chi tiết đơn hàng thành công' as RESULT,
					200 as CODE
		end

	end try
	begin catch
		rollback transaction
		select ERROR_MESSAGE() as RESULT,
				ERROR_NUMBER() as CODE
	end catch
    
END
GO
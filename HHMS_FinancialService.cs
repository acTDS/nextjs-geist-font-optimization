using System;
using System.Data;
using System.Data.SqlClient;
using System.Threading.Tasks;

namespace HHMS_Ngoaingu68
{
    public class FinancialService
    {
        private readonly HHMSDataAccess dataAccess;

        public FinancialService(HHMSDataAccess dataAccess)
        {
            this.dataAccess = dataAccess;
        }

        public async Task<DataTable> GetFinancialSummaryAsync(DateTime fromDate, DateTime toDate)
        {
            SqlParameter[] parameters = new SqlParameter[]
            {
                new SqlParameter("@FromDate", SqlDbType.Date) { Value = fromDate },
                new SqlParameter("@ToDate", SqlDbType.Date) { Value = toDate }
            };

            return await dataAccess.ExecuteStoredProcedureAsync("SP_GetFinancialSummary", parameters);
        }

        public async Task<int> AddFinancialTransactionAsync(
            int branchId,
            DateTime transactionDate,
            int transactionTypeId,
            string description,
            decimal amount,
            DateTime? dueDate,
            DateTime? paymentDate,
            int? relatedPurchaseRequestId,
            int? relatedTuitionId,
            int statusId)
        {
            SqlParameter[] parameters = new SqlParameter[]
            {
                new SqlParameter("@BranchID", SqlDbType.Int) { Value = branchId },
                new SqlParameter("@TransactionDate", SqlDbType.Date) { Value = transactionDate },
                new SqlParameter("@TransactionTypeID", SqlDbType.Int) { Value = transactionTypeId },
                new SqlParameter("@Description", SqlDbType.NVarChar, 255) { Value = description },
                new SqlParameter("@Amount", SqlDbType.Decimal) { Value = amount },
                new SqlParameter("@DueDate", SqlDbType.Date) { Value = (object)dueDate ?? DBNull.Value },
                new SqlParameter("@PaymentDate", SqlDbType.Date) { Value = (object)paymentDate ?? DBNull.Value },
                new SqlParameter("@RelatedPurchaseRequestID", SqlDbType.Int) { Value = (object)relatedPurchaseRequestId ?? DBNull.Value },
                new SqlParameter("@RelatedTuitionID", SqlDbType.Int) { Value = (object)relatedTuitionId ?? DBNull.Value },
                new SqlParameter("@StatusID", SqlDbType.Int) { Value = statusId }
            };

            return await dataAccess.ExecuteNonQueryAsync("SP_AddFinancialTransaction", parameters);
        }
    }
}

export const PledgeSummary = ({ summary }) => {
  // Provide default values if summary properties are missing
  const totalPledged = summary?.total_pledged || 0;
  const totalPaid = summary?.total_paid || 0;
  const totalBalance = summary?.total_balance || 0;
  const collectionRate = summary?.collection_rate || 0;

  return (
    <div className="pledge-summary-cards">
      <div className="summary-card">
        <h4>Total Pledged</h4>
        <p className="summary-amount">TZS {totalPledged.toLocaleString()}</p>
      </div>
      <div className="summary-card">
        <h4>Total Collected</h4>
        <p className="summary-amount collected">TZS {totalPaid.toLocaleString()}</p>
      </div>
      <div className="summary-card">
        <h4>Outstanding Balance</h4>
        <p className="summary-amount balance">TZS {totalBalance.toLocaleString()}</p>
      </div>
      <div className="summary-card">
        <h4>Collection Rate</h4>
        <div className="collection-rate">
          <div className="rate-circle">
            <span>{collectionRate.toFixed(1)}%</span>
          </div>
        </div>
      </div>
    </div>
  );
};
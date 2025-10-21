export const PledgeSummary = ({ summary }) => {
    return (
      <div className="pledge-summary-cards">
        <div className="summary-card">
          <h4>Total Pledged</h4>
          <p className="summary-amount">TZS {summary.total_pledged.toLocaleString()}</p>
        </div>
        <div className="summary-card">
          <h4>Total Collected</h4>
          <p className="summary-amount collected">TZS {summary.total_paid.toLocaleString()}</p>
        </div>
        <div className="summary-card">
          <h4>Outstanding Balance</h4>
          <p className="summary-amount balance">TZS {summary.total_balance.toLocaleString()}</p>
        </div>
        <div className="summary-card">
          <h4>Collection Rate</h4>
          <div className="collection-rate">
            <div className="rate-circle">
              <span>{summary.collection_rate.toFixed(1)}%</span>
            </div>
          </div>
        </div>
      </div>
    );
  };
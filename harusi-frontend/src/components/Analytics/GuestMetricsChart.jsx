import { PieChart, Pie, Cell, BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, Legend, ResponsiveContainer } from 'recharts';

export const GuestMetricsChart = ({ comparison }) => {
  const guestData = [
    { name: 'Confirmed', value: comparison.guests.confirmed, color: '#10b981' },
    { name: 'Pending', value: comparison.guests.pending, color: '#f59e0b' },
    { name: 'Declined', value: comparison.guests.declined, color: '#ef4444' }
  ];

  const responseRate = (
    (comparison.guests.confirmed + comparison.guests.declined) / 
    comparison.guests.invited * 100
  ).toFixed(1);

  return (
    <div className="chart-container card">
      <h3>👥 Guest Response Analytics</h3>

      <div className="chart-stats">
        <div className="stat">
          <span className="label">Total Invitations:</span>
          <span className="value">{comparison.guests.invited}</span>
        </div>
        <div className="stat">
          <span className="label">Confirmed:</span>
          <span className="value confirmed">{comparison.guests.confirmed}</span>
        </div>
        <div className="stat">
          <span className="label">Pending:</span>
          <span className="value pending">{comparison.guests.pending}</span>
        </div>
        <div className="stat">
          <span className="label">Response Rate:</span>
          <span className="value">{responseRate}%</span>
        </div>
      </div>

      <ResponsiveContainer width="100%" height={300}>
        <PieChart>
          <Pie
            data={guestData}
            cx="50%"
            cy="50%"
            labelLine={false}
            label={({ name, value }) => `${name}: ${value}`}
            outerRadius={100}
            fill="#8884d8"
            dataKey="value"
          >
            {guestData.map((entry, index) => (
              <Cell key={`cell-${index}`} fill={entry.color} />
            ))}
          </Pie>
          <Tooltip />
        </PieChart>
      </ResponsiveContainer>
    </div>
  );
};
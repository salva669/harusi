import { useState, useEffect } from 'react';
import { budgetAPI } from '../../services/api';
import { BudgetForm } from './BudgetForm';
import { Loading } from '../Common/Loading';
import './Budget.css';

export const BudgetSummary = ({ weddingId }) => {
  const [budgetItems, setBudgetItems] = useState([]);
  const [loading, setLoading] = useState(true);
  const [showForm, setShowForm] = useState(false);
  const [editingItem, setEditingItem] = useState(null);

  useEffect(() => {
    loadBudget();
  }, [weddingId]);

  const loadBudget = async () => {
    try {
      const response = await budgetAPI.getAll(weddingId);
      setBudgetItems(response.data);
    } catch (err) {
      console.error('Failed to load budget');
    } finally {
      setLoading(false);
    }
  };

  const handleDelete = async (itemId) => {
    if (window.confirm('Delete this budget item?')) {
      try {
        await budgetAPI.delete(weddingId, itemId);
        setBudgetItems(budgetItems.filter(item => item.id !== itemId));
      } catch (err) {
        console.error('Failed to delete budget item');
      }
    }
  };

  const handleSave = () => {
    loadBudget();
    setShowForm(false);
    setEditingItem(null);
  };

  if (loading) return <Loading />;

  const categories = [...new Set(budgetItems.map(item => item.category))];
  
  const totalEstimated = budgetItems.reduce((sum, item) => sum + parseFloat(item.estimated_cost || 0), 0);
  const totalActual = budgetItems.reduce((sum, item) => sum + parseFloat(item.actual_cost || 0), 0);
  const remaining = totalEstimated - totalActual;

  const categoryTotals = {};
  categories.forEach(cat => {
    const items = budgetItems.filter(item => item.category === cat);
    categoryTotals[cat] = {
      estimated: items.reduce((sum, item) => sum + parseFloat(item.estimated_cost || 0), 0),
      actual: items.reduce((sum, item) => sum + parseFloat(item.actual_cost || 0), 0),
    };
  });

  return (
    <div>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '20px' }}>
        <h2>Budget Planning</h2>
        <button className="primary" onClick={() => setShowForm(!showForm)}>
          {showForm ? '✕ Cancel' : '+ Add Item'}
        </button>
      </div>

      {showForm && (
        <BudgetForm 
          weddingId={weddingId}
          item={editingItem}
          onSave={handleSave}
          onCancel={() => { setShowForm(false); setEditingItem(null); }}
        />
      )}

      <div className="budget-summary-cards">
        <div className="budget-card">
          <h4>Total Budget</h4>
          <p className="budget-amount">TZS {totalEstimated.toLocaleString()}</p>
          <p className="budget-label">Estimated</p>
        </div>
        <div className="budget-card">
          <h4>Spent</h4>
          <p className="budget-amount" style={{ color: '#ef4444' }}>
            TZS {totalActual.toLocaleString()}
          </p>
          <p className="budget-label">Actual Cost</p>
        </div>
        <div className="budget-card">
          <h4>Remaining</h4>
          <p className={`budget-amount ${remaining >= 0 ? 'positive' : 'negative'}`}>
            TZS {Math.abs(remaining).toLocaleString()}
          </p>
          <p className="budget-label">{remaining >= 0 ? 'To Spend' : 'Over Budget'}</p>
        </div>
        <div className="budget-card">
          <h4>Progress</h4>
          <div className="progress-bar">
            <div 
              className="progress-fill" 
              style={{ width: `${Math.min((totalActual / totalEstimated) * 100, 100)}%` }}
            ></div>
          </div>
          <p className="budget-label">{Math.round((totalActual / totalEstimated) * 100)}%</p>
        </div>
      </div>

      {budgetItems.length === 0 ? (
        <div className="empty-state">
          <p>No budget items yet. Start planning your budget!</p>
        </div>
      ) : (
        <>
          <div className="budget-by-category">
            <h3>Budget by Category</h3>
            {categories.map(cat => (
              <div key={cat} className="category-row">
                <span className="category-name">{cat}</span>
                <div className="category-amounts">
                  <span>Est: TZS {categoryTotals[cat].estimated.toLocaleString()}</span>
                  <span>Actual: TZS {categoryTotals[cat].actual.toLocaleString()}</span>
                </div>
              </div>
            ))}
          </div>

          <div className="budget-items">
            <h3>Budget Items</h3>
            {budgetItems.map(item => (
              <div key={item.id} className="budget-item card">
                <div className="budget-item-header">
                  <div>
                    <h4>{item.item_name}</h4>
                    <p className="budget-category">{item.category}</p>
                  </div>
                  <div className="budget-item-amounts">
                    <div className="amount">
                      <span className="label">Est:</span>
                      <span className="value">TZS {item.estimated_cost.toLocaleString()}</span>
                    </div>
                    {item.actual_cost && (
                      <div className="amount">
                        <span className="label">Actual:</span>
                        <span className="value" style={{ color: '#ef4444' }}>
                          TZS {item.actual_cost.toLocaleString()}
                        </span>
                      </div>
                    )}
                  </div>
                </div>
                {item.notes && <p className="budget-notes">{item.notes}</p>}
                <div className="budget-item-actions">
                  <button 
                    className="secondary" 
                    onClick={() => { setEditingItem(item); setShowForm(true); }}
                  >
                    Edit
                  </button>
                  <button 
                    className="danger" 
                    onClick={() => handleDelete(item.id)}
                  >
                    Delete
                  </button>
                </div>
              </div>
            ))}
          </div>
        </>
      )}
    </div>
  );
};
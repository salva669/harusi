import api from '../../services/api';
import './Reports.css';

export const PDFDownloads = ({ weddingId }) => {
  const handleDownload = async (endpoint, filename) => {
    try {
      const response = await api.get(endpoint, { responseType: 'blob' });
      const url = window.URL.createObjectURL(new Blob([response.data]));
      const link = document.createElement('a');
      link.href = url;
      link.setAttribute('download', filename);
      document.body.appendChild(link);
      link.click();
      link.parentChild.removeChild(link);
    } catch (err) {
      console.error('Failed to download PDF');
    }
  };

  return (
    <div className="pdf-downloads card">
      <h3>📄 Download Reports</h3>
      <p>Export your wedding information as PDF documents</p>
      
      <div className="pdf-buttons">
        <button 
          className="primary" 
          onClick={() => handleDownload(
            `/weddings/${weddingId}/pdf/guest-list/`,
            'guest-list.pdf'
          )}
        >
          📋 Guest List
        </button>
        <button 
          className="primary" 
          onClick={() => handleDownload(
            `/weddings/${weddingId}/pdf/budget/`,
            'budget-report.pdf'
          )}
        >
          💰 Budget Report
        </button>
        <button 
          className="primary" 
          onClick={() => handleDownload(
            `/weddings/${weddingId}/pdf/timeline/`,
            'timeline.pdf'
          )}
        >
          📅 Timeline
        </button>
        <button 
          className="primary" 
          onClick={() => handleDownload(
            `/weddings/${weddingId}/pdf/vendors/`,
            'vendor-list.pdf'
          )}
        >
          💼 Vendor List
        </button>
        <button 
          className="primary" 
          onClick={() => handleDownload(
            `/weddings/${weddingId}/pdf/invitation/`,
            'invitation.pdf'
          )}
        >
          💌 Invitation Card
        </button>
      </div>
    </div>
  );
};
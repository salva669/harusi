import './Gallery.css';

export const PhotoGallery = ({ weddingId }) => {
  return (
    <div className="photo-gallery">
      <div className="coming-soon-container">
        <div className="coming-soon-icon">📸</div>
        <h2>Photo Gallery</h2>
        <p className="coming-soon-text">Coming Soon!</p>
        <p className="coming-soon-description">
          We're working on an amazing photo gallery feature where you'll be able to:
        </p>
        <ul className="coming-soon-features">
          <li>📷 Create multiple photo albums</li>
          <li>🖼️ Upload and organize wedding photos</li>
          <li>🎨 Categorize by ceremony, reception, pre-wedding, etc.</li>
          <li>💬 Add captions and descriptions</li>
          <li>👥 Share albums with guests</li>
        </ul>
        <p className="coming-soon-footer">Stay tuned for updates!</p>
      </div>
    </div>
  );
};
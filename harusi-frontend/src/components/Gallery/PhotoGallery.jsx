import { useState, useEffect } from 'react';
import { galleryAPI, photoAPI } from '../../services/api';
import { Loading } from '../Common/Loading';
import './Gallery.css';

export const PhotoGallery = ({ weddingId }) => {
  const [galleries, setGalleries] = useState([]);
  const [loading, setLoading] = useState(true);
  const [selectedGallery, setSelectedGallery] = useState(null);
  const [showNewGallery, setShowNewGallery] = useState(false);
  const [newGalleryData, setNewGalleryData] = useState({
    title: '',
    album_type: 'other',
    description: '',
  });

  useEffect(() => {
    loadGalleries();
  }, [weddingId]);

  const loadGalleries = async () => {
    try {
      const response = await galleryAPI.getAll(weddingId);
      setGalleries(response.data);
    } catch (err) {
      console.error('Failed to load galleries');
    } finally {
      setLoading(false);
    }
  };

  const handleCreateGallery = async (e) => {
    e.preventDefault();
    try {
      await galleryAPI.create(weddingId, newGalleryData);
      loadGalleries();
      setShowNewGallery(false);
      setNewGalleryData({ title: '', album_type: 'other', description: '' });
    } catch (err) {
      console.error('Failed to create gallery');
    }
  };

  const handleUploadPhoto = async (galleryId, file) => {
    const formData = new FormData();
    formData.append('image', file);
    formData.append('caption', file.name);
    
    try {
      await photoAPI.create(weddingId, galleryId, formData);
      loadGalleries();
    } catch (err) {
      console.error('Failed to upload photo');
    }
  };

  if (loading) return <Loading />;

  return (
    <div className="photo-gallery">
      <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '20px' }}>
        <h2>📸 Photo Gallery</h2>
        <button className="primary" onClick={() => setShowNewGallery(!showNewGallery)}>
          {showNewGallery ? '✕ Cancel' : '+ New Album'}
        </button>
      </div>

      {showNewGallery && (
        <form onSubmit={handleCreateGallery} className="card">
          <div className="form-group">
            <label>Album Title</label>
            <input
              type="text"
              value={newGalleryData.title}
              onChange={(e) => setNewGalleryData({ ...newGalleryData, title: e.target.value })}
              required
            />
          </div>
          <div className="form-group">
            <label>Album Type</label>
            <select
              value={newGalleryData.album_type}
              onChange={(e) => setNewGalleryData({ ...newGalleryData, album_type: e.target.value })}
            >
              <option value="pre_wedding">Pre-Wedding</option>
              <option value="ceremony">Ceremony</option>
              <option value="reception">Reception</option>
              <option value="other">Other</option>
            </select>
          </div>
          <button type="submit" className="primary">Create Album</button>
        </form>
      )}

      <div className="gallery-grid">
        {galleries.map(gallery => (
          <div key={gallery.id} className="gallery-album card">
            <h3>{gallery.title}</h3>
            <p className="album-type">{gallery.album_type}</p>
            <p className="photo-count">📷 {gallery.photos.length} photos</p>
            
            <div className="album-preview">
              {gallery.photos.slice(0, 4).map(photo => (
                <img key={photo.id} src={photo.image} alt={photo.caption} />
              ))}
            </div>
            
            <label className="upload-btn">
              📸 Add Photos
              <input
                type="file"
                multiple
                accept="image/*"
                onChange={(e) => {
                  Array.from(e.target.files).forEach(file => {
                    handleUploadPhoto(gallery.id, file);
                  });
                }}
                style={{ display: 'none' }}
              />
            </label>
          </div>
        ))}
      </div>
    </div>
  );
};

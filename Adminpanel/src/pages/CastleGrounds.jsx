import { useState } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { castleGroundsAPI } from '../services/api';
import DataTable from '../components/DataTable';
import Modal from '../components/Modal';
import './CastleGrounds.css';

const CastleGrounds = () => {
  // Page State
  const [page, setPage] = useState(1);

  // UI State
  const [viewModalOpen, setViewModalOpen] = useState(false);
  const [editModalOpen, setEditModalOpen] = useState(false);
  const [selectedCastle, setSelectedCastle] = useState(null);
  const [editFormData, setEditFormData] = useState({ level: '', coins: '', stones: '', wood: '' });

  // React Query for data fetching
  const { data, isLoading } = useQuery({
    queryKey: ['castleGrounds', page],
    queryFn: async () => {
      const response = await castleGroundsAPI.getAll(page, 20);
      return response.data;
    },
    keepPreviousData: true,
  });

  const castles = data?.castles || [];
  const totalPages = data?.pagination?.pages || 1;
  const loading = isLoading;

  // React Query for mutations
  const queryClient = useQueryClient();

  const updateMutation = useMutation({
    mutationFn: (data) => castleGroundsAPI.update(selectedCastle.id || selectedCastle._id, data),
    onSuccess: () => {
      queryClient.invalidateQueries(['castleGrounds']);
      setEditModalOpen(false);
      setSelectedCastle(null);
    },
    onError: (error) => {
      console.error('Error updating castle:', error);
      alert('Failed to update castle');
    }
  });

  const handleSaveEdit = () => {
    if (selectedCastle) {
      updateMutation.mutate(editFormData);
    }
  };

  const columns = [
    {
      key: 'id',
      label: 'Castle ID',
      render: (value, row) => row.id || row._id || '-'
    },
    {
      key: 'userId',
      label: 'User',
      render: (value) => {
        if (typeof value === 'object' && value !== null) {
          return value.name || value.email || value._id || JSON.stringify(value);
        }
        return value;
      }
    },
    { key: 'level', label: 'Level' },
    { key: 'levelName', label: 'Level Name' },
    {
      key: 'coins',
      label: 'Resources',
      render: (value, row) => (
        <div className="resources-cell">
          <span>💰 {value.toLocaleString()}</span>
          <span>🪨 {row.stones.toLocaleString()}</span>
          <span>🪵 {row.wood.toLocaleString()}</span>
        </div>
      ),
    },
    {
      key: 'progressPercentage',
      label: 'Progress',
      render: (value) => (
        <div className="progress-bar-container">
          <div className="progress-bar" style={{ width: `${value}%` }}></div>
          <span className="progress-text">{value.toFixed(1)}%</span>
        </div>
      ),
    },
    {
      key: 'updatedAt',
      label: 'Last Updated',
      render: (value) => (value ? new Date(value).toLocaleString() : '-'),
    },
  ];

  return (
    <div className="castle-grounds-page">
      <div className="page-header">
        <h2>Castle Grounds</h2>
      </div>

      <DataTable
        columns={columns}
        data={castles}
        loading={loading}
        actions={(row) => (
          <>
            <button className="btn-view" onClick={() => {
              setSelectedCastle(row);
              setViewModalOpen(true);
            }}>
              View
            </button>
            <button className="btn-edit" onClick={() => {
              setSelectedCastle(row);
              setEditFormData({
                level: row.level || '',
                coins: row.coins || '',
                stones: row.stones || '',
                wood: row.wood || '',
              });
              setEditModalOpen(true);
            }}>
              Edit
            </button>
          </>
        )}
      />

      {/* View Modal */}
      <Modal
        isOpen={viewModalOpen}
        onClose={() => {
          setViewModalOpen(false);
          setSelectedCastle(null);
        }}
        title="Castle Details"
        size="medium"
      >
        {selectedCastle && (
          <div className="user-details">
            <div className="detail-row">
              <span className="detail-label">Castle ID:</span>
              <span className="detail-value">{selectedCastle.id || selectedCastle._id}</span>
            </div>
            <div className="detail-row">
              <span className="detail-label">User:</span>
              <span className="detail-value">
                {selectedCastle.userId?.name || selectedCastle.userId?.email || selectedCastle.userId || 'N/A'}
              </span>
            </div>
            <div className="detail-row">
              <span className="detail-label">Level:</span>
              <span className="detail-value">{selectedCastle.level}</span>
            </div>
            <div className="detail-row">
              <span className="detail-label">Level Name:</span>
              <span className="detail-value">{selectedCastle.levelName}</span>
            </div>
            <div className="detail-row">
              <span className="detail-label">Coins:</span>
              <span className="detail-value">💰 {selectedCastle.coins?.toLocaleString() || 0}</span>
            </div>
            <div className="detail-row">
              <span className="detail-label">Stones:</span>
              <span className="detail-value">🪨 {selectedCastle.stones?.toLocaleString() || 0}</span>
            </div>
            <div className="detail-row">
              <span className="detail-label">Wood:</span>
              <span className="detail-value">🪵 {selectedCastle.wood?.toLocaleString() || 0}</span>
            </div>
            <div className="detail-row">
              <span className="detail-label">Progress:</span>
              <span className="detail-value">{selectedCastle.progressPercentage?.toFixed(1) || 0}%</span>
            </div>
          </div>
        )}
      </Modal>

      {/* Edit Modal */}
      <Modal
        isOpen={editModalOpen}
        onClose={() => {
          setEditModalOpen(false);
          setSelectedCastle(null);
        }}
        title="Edit Castle"
        size="medium"
      >
        <div className="edit-form">
          <div className="form-group">
            <label htmlFor="edit-level">Level</label>
            <input
              type="number"
              id="edit-level"
              value={editFormData.level}
              onChange={(e) => setEditFormData({ ...editFormData, level: e.target.value })}
              className="form-input"
            />
          </div>
          <div className="form-group">
            <label htmlFor="edit-coins">Coins</label>
            <input
              type="number"
              id="edit-coins"
              value={editFormData.coins}
              onChange={(e) => setEditFormData({ ...editFormData, coins: e.target.value })}
              className="form-input"
            />
          </div>
          <div className="form-group">
            <label htmlFor="edit-stones">Stones</label>
            <input
              type="number"
              id="edit-stones"
              value={editFormData.stones}
              onChange={(e) => setEditFormData({ ...editFormData, stones: e.target.value })}
              className="form-input"
            />
          </div>
          <div className="form-group">
            <label htmlFor="edit-wood">Wood</label>
            <input
              type="number"
              id="edit-wood"
              value={editFormData.wood}
              onChange={(e) => setEditFormData({ ...editFormData, wood: e.target.value })}
              className="form-input"
            />
          </div>
          <div className="modal-footer">
            <button
              className="modal-button modal-button-secondary"
              onClick={() => {
                setEditModalOpen(false);
                setSelectedCastle(null);
              }}
            >
              Cancel
            </button>
            <button
              className="modal-button modal-button-primary"
              onClick={handleSaveEdit}
            >
              Save Changes
            </button>
          </div>
        </div>
      </Modal>

      <div className="pagination">
        <button
          onClick={() => setPage((p) => Math.max(1, p - 1))}
          disabled={page === 1}
        >
          Previous
        </button>
        <span>
          Page {page} of {totalPages}
        </span>
        <button
          onClick={() => setPage((p) => Math.min(totalPages, p + 1))}
          disabled={page === totalPages}
        >
          Next
        </button>
      </div>
    </div>
  );
};

export default CastleGrounds;


import { useState } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { treasureChestsAPI } from '../services/api';
import DataTable from '../components/DataTable';
import Modal from '../components/Modal';
import './TreasureChests.css';

const TreasureChests = () => {
  // Page State
  const [page, setPage] = useState(1);

  // UI State
  const [viewModalOpen, setViewModalOpen] = useState(false);
  const [editModalOpen, setEditModalOpen] = useState(false);
  const [selectedChest, setSelectedChest] = useState(null);
  const [editFormData, setEditFormData] = useState({ progressPercentage: '', isUnlocked: false, isClaimed: false });

  // React Query for data fetching
  const { data, isLoading } = useQuery({
    queryKey: ['treasureChests', page],
    queryFn: async () => {
      const response = await treasureChestsAPI.getAll(page, 20);
      return response.data;
    },
    keepPreviousData: true,
  });

  const chests = data?.chests || [];
  const totalPages = data?.pagination?.pages || 1;
  const loading = isLoading;

  // React Query for mutations
  const queryClient = useQueryClient();

  const updateMutation = useMutation({
    mutationFn: (data) => treasureChestsAPI.update(selectedChest.id || selectedChest._id, data),
    onSuccess: () => {
      queryClient.invalidateQueries(['treasureChests']);
      setEditModalOpen(false);
      setSelectedChest(null);
    },
    onError: (error) => {
      console.error('Error updating chest:', error);
      alert('Failed to update chest');
    }
  });

  const handleSaveEdit = () => {
    if (selectedChest) {
      updateMutation.mutate(editFormData);
    }
  };

  const columns = [
    { key: 'id', label: 'Chest ID', render: (value, row) => row.id || row._id || '-' },
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
    {
      key: 'progressPercentage',
      label: 'Progress',
      render: (value) => (
        <div className="progress-bar-container">
          <div className="progress-bar" style={{ width: `${value || 0}%` }}></div>
          <span className="progress-text">{(value || 0).toFixed(1)}%</span>
        </div>
      ),
    },
    {
      key: 'isUnlocked',
      label: 'Status',
      render: (value, row) => (
        <div className="chest-status">
          <span className={`status-badge ${value ? 'unlocked' : 'locked'}`}>
            {value ? '🔓 Unlocked' : '🔒 Locked'}
          </span>
          {row.isClaimed && (
            <span className="status-badge claimed">✓ Claimed</span>
          )}
        </div>
      ),
    },
    {
      key: 'rewards',
      label: 'Rewards',
      render: (value) => (
        <div className="rewards-list">
          {value?.map((reward, index) => (
            <span
              key={reward.id || reward._id || index}
              className="reward-badge"
              style={{ backgroundColor: `${reward.colorHex}20`, color: reward.colorHex }}
            >
              {reward.title}
            </span>
          ))}
        </div>
      ),
    },
    {
      key: 'unlockedAt',
      label: 'Unlocked At',
      render: (value) => (value ? new Date(value).toLocaleString() : '-'),
    },
  ];

  return (
    <div className="treasure-chests-page">
      <div className="page-header">
        <h2>Treasure Chests</h2>
      </div>

      <DataTable
        columns={columns}
        data={chests}
        loading={loading}
        actions={(row) => (
          <>
            <button className="btn-view" onClick={() => {
              setSelectedChest(row);
              setViewModalOpen(true);
            }}>
              View
            </button>
            <button className="btn-edit" onClick={() => {
              setSelectedChest(row);
              setEditFormData({
                progressPercentage: row.progressPercentage || '',
                isUnlocked: row.isUnlocked || false,
                isClaimed: row.isClaimed || false,
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
          setSelectedChest(null);
        }}
        title="Treasure Chest Details"
        size="medium"
      >
        {selectedChest && (
          <div className="user-details">
            <div className="detail-row">
              <span className="detail-label">Chest ID:</span>
              <span className="detail-value">{selectedChest.id || selectedChest._id}</span>
            </div>
            <div className="detail-row">
              <span className="detail-label">User:</span>
              <span className="detail-value">
                {selectedChest.userId?.name || selectedChest.userId?.email || selectedChest.userId || 'N/A'}
              </span>
            </div>
            <div className="detail-row">
              <span className="detail-label">Progress:</span>
              <span className="detail-value">{selectedChest.progressPercentage?.toFixed(1) || 0}%</span>
            </div>
            <div className="detail-row">
              <span className="detail-label">Status:</span>
              <span className="detail-value">
                <span className={`status-badge ${selectedChest.isUnlocked ? 'unlocked' : 'locked'}`}>
                  {selectedChest.isUnlocked ? '🔓 Unlocked' : '🔒 Locked'}
                </span>
                {selectedChest.isClaimed && (
                  <span className="status-badge claimed" style={{ marginLeft: '8px' }}>✓ Claimed</span>
                )}
              </span>
            </div>
            <div className="detail-row">
              <span className="detail-label">Rewards:</span>
              <span className="detail-value">
                <div className="rewards-list">
                  {selectedChest.rewards?.map((reward) => (
                    <span
                      key={reward.id}
                      className="reward-badge"
                      style={{ backgroundColor: `${reward.colorHex}20`, color: reward.colorHex }}
                    >
                      {reward.title}
                    </span>
                  ))}
                </div>
              </span>
            </div>
            <div className="detail-row">
              <span className="detail-label">Unlocked At:</span>
              <span className="detail-value">
                {selectedChest.unlockedAt ? new Date(selectedChest.unlockedAt).toLocaleString() : 'N/A'}
              </span>
            </div>
            <div className="detail-row">
              <span className="detail-label">Claimed At:</span>
              <span className="detail-value">
                {selectedChest.claimedAt ? new Date(selectedChest.claimedAt).toLocaleString() : 'N/A'}
              </span>
            </div>
          </div>
        )}
      </Modal>

      {/* Edit Modal */}
      <Modal
        isOpen={editModalOpen}
        onClose={() => {
          setEditModalOpen(false);
          setSelectedChest(null);
        }}
        title="Edit Treasure Chest"
        size="medium"
      >
        <div className="edit-form">
          <div className="form-group">
            <label htmlFor="edit-progress">Progress (%)</label>
            <input
              type="number"
              id="edit-progress"
              min="0"
              max="100"
              value={editFormData.progressPercentage}
              onChange={(e) => setEditFormData({ ...editFormData, progressPercentage: e.target.value })}
              className="form-input"
            />
          </div>
          <div className="form-group">
            <label style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
              <input
                type="checkbox"
                checked={editFormData.isUnlocked}
                onChange={(e) => setEditFormData({ ...editFormData, isUnlocked: e.target.checked })}
              />
              Unlocked
            </label>
          </div>
          <div className="form-group">
            <label style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
              <input
                type="checkbox"
                checked={editFormData.isClaimed}
                onChange={(e) => setEditFormData({ ...editFormData, isClaimed: e.target.checked })}
              />
              Claimed
            </label>
          </div>
          <div className="modal-footer">
            <button
              className="modal-button modal-button-secondary"
              onClick={() => {
                setEditModalOpen(false);
                setSelectedChest(null);
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

export default TreasureChests;


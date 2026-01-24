import { useState } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { usersAPI } from '../services/api';
import DataTable from '../components/DataTable';
import Modal from '../components/Modal';
import ConfirmModal from '../components/ConfirmModal';
import './Users.css';

const Users = () => {
  // Page State
  const [page, setPage] = useState(1);
  const [searchQuery, setSearchQuery] = useState('');

  // UI State
  const [viewModalOpen, setViewModalOpen] = useState(false);
  const [editModalOpen, setEditModalOpen] = useState(false);
  const [deleteModalOpen, setDeleteModalOpen] = useState(false);
  const [selectedUser, setSelectedUser] = useState(null);
  const [editFormData, setEditFormData] = useState({ name: '', email: '' });

  // React Query for data fetching
  const { data, isLoading } = useQuery({
    queryKey: ['users', page, searchQuery],
    queryFn: async () => {
      const response = searchQuery
        ? await usersAPI.search(searchQuery)
        : await usersAPI.getAll(page, 20);
      return response.data;
    },
    keepPreviousData: true, // Show previous page data while loading new one
  });

  const users = data?.users || [];
  const totalPages = data?.pagination?.pages || 1;
  const loading = isLoading;

  // React Query for mutations
  const queryClient = useQueryClient();

  const updateMutation = useMutation({
    mutationFn: (data) => usersAPI.update(selectedUser.id || selectedUser._id, data),
    onSuccess: () => {
      queryClient.invalidateQueries(['users']);
      setEditModalOpen(false);
      setSelectedUser(null);
    },
    onError: (error) => {
      console.error('Error updating user:', error);
      alert('Failed to update user');
    }
  });

  const deleteMutation = useMutation({
    mutationFn: () => usersAPI.delete(selectedUser.id || selectedUser._id),
    onSuccess: () => {
      queryClient.invalidateQueries(['users']);
      setDeleteModalOpen(false);
      setSelectedUser(null);
    },
    onError: (error) => {
      console.error('Error deleting user:', error);
      alert('Failed to delete user');
    }
  });


  const handleView = (user) => {
    setSelectedUser(user);
    setViewModalOpen(true);
  };

  const handleEdit = (user) => {
    setSelectedUser(user);
    setEditFormData({
      name: user.name || '',
      email: user.email || '',
    });
    setEditModalOpen(true);
  };

  const handleSaveEdit = () => {
    if (!selectedUser) return;
    updateMutation.mutate(editFormData);
  };

  const handleDelete = (user) => {
    setSelectedUser(user);
    setDeleteModalOpen(true);
  };

  const confirmDelete = () => {
    if (!selectedUser) return;
    deleteMutation.mutate(selectedUser.id);
  };

  const columns = [
    {
      key: 'id',
      label: 'ID',
      render: (value, row) => row.id || row._id || '-'
    },
    {
      key: 'name',
      label: 'Name',
      render: (value, row) => (
        <div className="user-cell">
          {row.avatar && (
            <img src={row.avatar} alt={value} className="user-avatar" />
          )}
          <span>{value || 'N/A'}</span>
        </div>
      ),
    },
    { key: 'email', label: 'Email' },
    {
      key: 'createdAt',
      label: 'Created At',
      render: (value) => (value ? new Date(value).toLocaleDateString() : '-'),
    },
  ];

  return (
    <div className="users-page">
      <div className="page-header">
        <h2>Users Management</h2>
        <div className="page-actions">
          <input
            type="text"
            placeholder="Search users..."
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            className="search-input"
          />
        </div>
      </div>

      <DataTable
        columns={columns}
        data={users}
        loading={loading}
        actions={(row) => (
          <>
            <button className="btn-view" onClick={() => handleView(row)}>
              View
            </button>
            <button className="btn-edit" onClick={() => handleEdit(row)}>
              Edit
            </button>
            <button className="btn-delete" onClick={() => handleDelete(row)}>
              Delete
            </button>
          </>
        )}
      />

      {/* View Modal */}
      <Modal
        isOpen={viewModalOpen}
        onClose={() => {
          setViewModalOpen(false);
          setSelectedUser(null);
        }}
        title="User Details"
        size="medium"
      >
        {selectedUser && (
          <div className="user-details">
            <div className="detail-row">
              <span className="detail-label">ID:</span>
              <span className="detail-value">{selectedUser.id || selectedUser._id}</span>
            </div>
            <div className="detail-row">
              <span className="detail-label">Name:</span>
              <span className="detail-value">{selectedUser.name || 'N/A'}</span>
            </div>
            <div className="detail-row">
              <span className="detail-label">Email:</span>
              <span className="detail-value">{selectedUser.email || 'N/A'}</span>
            </div>
            <div className="detail-row">
              <span className="detail-label">Created At:</span>
              <span className="detail-value">
                {selectedUser.createdAt ? new Date(selectedUser.createdAt).toLocaleString() : 'N/A'}
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
          setSelectedUser(null);
        }}
        title="Edit User"
        size="medium"
      >
        <div className="edit-form">
          <div className="form-group">
            <label htmlFor="edit-name">Name</label>
            <input
              type="text"
              id="edit-name"
              value={editFormData.name}
              onChange={(e) => setEditFormData({ ...editFormData, name: e.target.value })}
              className="form-input"
            />
          </div>
          <div className="form-group">
            <label htmlFor="edit-email">Email</label>
            <input
              type="email"
              id="edit-email"
              value={editFormData.email}
              onChange={(e) => setEditFormData({ ...editFormData, email: e.target.value })}
              className="form-input"
            />
          </div>
          <div className="modal-footer">
            <button
              className="modal-button modal-button-secondary"
              onClick={() => {
                setEditModalOpen(false);
                setSelectedUser(null);
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

      {/* Delete Confirmation Modal */}
      <ConfirmModal
        isOpen={deleteModalOpen}
        onClose={() => {
          setDeleteModalOpen(false);
          setSelectedUser(null);
        }}
        onConfirm={confirmDelete}
        title="Delete User"
        message={`Are you sure you want to delete ${selectedUser?.name || selectedUser?.email || 'this user'}? This action cannot be undone.`}
        confirmText="Delete"
        cancelText="Cancel"
        type="danger"
      />

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

export default Users;


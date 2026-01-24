import mongoose from 'mongoose';

const globalSettingSchema = new mongoose.Schema({
    key: {
        type: String,
        required: true,
        unique: true
    },
    value: {
        type: mongoose.Schema.Types.Mixed,
        required: true
    },
    description: String,
    updatedBy: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User'
    }
}, {
    timestamps: true
});

const GlobalSetting = mongoose.model('GlobalSetting', globalSettingSchema);

export default GlobalSetting;

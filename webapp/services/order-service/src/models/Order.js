const { Sequelize, DataTypes } = require('sequelize');
require('dotenv').config({ path: '../../.env' });

const sequelize = new Sequelize(
  process.env.DB_NAME,
  process.env.DB_USER,
  process.env.DB_PASS,
  {
    host: process.env.DB_HOST,
    dialect: 'postgres',
    logging: false
  }
);

const Order = sequelize.define('Order', {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true
  },
  user_id: {
    type: DataTypes.UUID,
    allowNull: false
  },
  items: {
    type: DataTypes.JSONB,
    allowNull: false
  },
  total: {
    type: DataTypes.FLOAT,
    allowNull: false
  },
  status: {
    type: DataTypes.STRING,
    defaultValue: 'pending' // pending, confirmed, shipped, delivered, cancelled
  },
  payment_id: {
    type: DataTypes.STRING
  },
  address: {
    type: DataTypes.TEXT,
    allowNull: false
  }
});

module.exports = { sequelize, Order };

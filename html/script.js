// Base Script UI JavaScript
class BaseScriptUI {
    constructor() {
        this.isVisible = false;
        this.playerData = {};
        this.init();
    }

    init() {
        this.setupEventListeners();
        this.hideLoading();
        this.updatePlayerInfo();
        
        // Listen for messages from the client
        window.addEventListener('message', (event) => {
            this.handleMessage(event.data);
        });
    }

    setupEventListeners() {
        // Close button
        document.getElementById('close-btn').addEventListener('click', () => {
            this.hideUI();
        });

        // Action buttons
        document.querySelectorAll('.action-btn').forEach(btn => {
            btn.addEventListener('click', (e) => {
                const action = e.currentTarget.dataset.action;
                this.handleAction(action);
            });
        });

        // Keyboard shortcuts
        document.addEventListener('keydown', (e) => {
            if (e.key === 'Escape' && this.isVisible) {
                this.hideUI();
            }
        });
    }

    handleMessage(data) {
        switch (data.type) {
            case 'showUI':
                this.showUI();
                break;
            case 'hideUI':
                this.hideUI();
                break;
            case 'updatePlayerData':
                this.updatePlayerData(data.playerData);
                break;
            case 'showNotification':
                this.showNotification(data.message, data.notificationType);
                break;
            case 'showToast':
                this.showToast(data.message, data.toastType);
                break;
            case 'updateMoney':
                this.updateMoney(data.money, data.bank);
                break;
        }
    }

    showUI() {
        const container = document.getElementById('ui-container');
        container.classList.remove('hidden');
        this.isVisible = true;
        
        // Animate in
        setTimeout(() => {
            container.style.opacity = '1';
            container.style.transform = 'scale(1)';
        }, 10);
    }

    hideUI() {
        const container = document.getElementById('ui-container');
        container.style.opacity = '0';
        container.style.transform = 'scale(0.9)';
        
        setTimeout(() => {
            container.classList.add('hidden');
            this.isVisible = false;
        }, 300);

        // Notify client that UI is hidden
        this.sendToClient('uiHidden');
    }

    handleAction(action) {
        switch (action) {
            case 'test':
                this.sendToClient('executeCommand', { command: 'test', args: ['Hello from UI!'] });
                break;
            case 'money':
                this.sendToClient('executeCommand', { command: 'money' });
                break;
            case 'coords':
                this.sendToClient('executeCommand', { command: 'coords' });
                break;
            case 'help':
                this.showHelp();
                break;
        }
    }

    showHelp() {
        const helpText = `
            <h3>Available Commands:</h3>
            <ul>
                <li><strong>/test [message]</strong> - Test command</li>
                <li><strong>/money</strong> - Check your money</li>
                <li><strong>/coords</strong> - Get your coordinates</li>
                <li><strong>/players</strong> - Show online players</li>
            </ul>
            <h3>Key Bindings:</h3>
            <ul>
                <li><strong>F1</strong> - Open help menu</li>
                <li><strong>F2</strong> - Quick action</li>
                <li><strong>F3</strong> - Toggle feature</li>
                <li><strong>ESC</strong> - Close UI</li>
            </ul>
        `;
        
        this.showNotification(helpText, 'info');
    }

    updatePlayerData(data) {
        this.playerData = { ...this.playerData, ...data };
        this.updatePlayerInfo();
    }

    updatePlayerInfo() {
        const nameElement = document.getElementById('player-name');
        const moneyElement = document.getElementById('player-money');
        const bankElement = document.getElementById('player-bank');
        const healthElement = document.getElementById('player-health');

        if (this.playerData.name) {
            nameElement.textContent = this.playerData.name;
        }
        
        if (this.playerData.money !== undefined) {
            moneyElement.textContent = `$${this.playerData.money.toLocaleString()}`;
        }
        
        if (this.playerData.bank !== undefined) {
            bankElement.textContent = `$${this.playerData.bank.toLocaleString()}`;
        }
        
        if (this.playerData.health !== undefined) {
            const healthPercent = Math.round((this.playerData.health / 200) * 100);
            healthElement.textContent = `${healthPercent}%`;
            
            // Color code health
            if (healthPercent > 75) {
                healthElement.style.color = '#2ecc71';
            } else if (healthPercent > 50) {
                healthElement.style.color = '#f39c12';
            } else {
                healthElement.style.color = '#e74c3c';
            }
        }
    }

    updateMoney(money, bank) {
        this.playerData.money = money;
        this.playerData.bank = bank;
        this.updatePlayerInfo();
    }

    showNotification(message, type = 'info') {
        const notificationsContainer = document.getElementById('notifications');
        
        const notification = document.createElement('div');
        notification.className = `notification ${type}`;
        
        const icon = this.getNotificationIcon(type);
        notification.innerHTML = `
            <i class="${icon}"></i>
            <span>${message}</span>
        `;
        
        notificationsContainer.appendChild(notification);
        
        // Auto-remove after 5 seconds
        setTimeout(() => {
            if (notification.parentNode) {
                notification.remove();
            }
        }, 5000);
    }

    showToast(message, type = 'info') {
        const toastContainer = document.getElementById('toast-container');
        
        const toast = document.createElement('div');
        toast.className = `toast ${type}`;
        
        const icon = this.getNotificationIcon(type);
        toast.innerHTML = `
            <i class="${icon}"></i>
            <span>${message}</span>
        `;
        
        toastContainer.appendChild(toast);
        
        // Auto-remove after 3 seconds
        setTimeout(() => {
            if (toast.parentNode) {
                toast.style.opacity = '0';
                toast.style.transform = 'translateX(100%)';
                setTimeout(() => {
                    if (toast.parentNode) {
                        toast.remove();
                    }
                }, 300);
            }
        }, 3000);
    }

    getNotificationIcon(type) {
        switch (type) {
            case 'success':
                return 'fas fa-check-circle';
            case 'error':
                return 'fas fa-times-circle';
            case 'warning':
                return 'fas fa-exclamation-triangle';
            default:
                return 'fas fa-info-circle';
        }
    }

    hideLoading() {
        const loading = document.getElementById('loading');
        loading.style.opacity = '0';
        setTimeout(() => {
            loading.style.display = 'none';
        }, 300);
    }

    sendToClient(action, data = {}) {
        fetch(`https://${GetParentResourceName()}/${action}`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify(data)
        }).catch(err => {
            console.error('Failed to send message to client:', err);
        });
    }

    // Utility functions
    formatNumber(num) {
        return num.toLocaleString();
    }

    formatCurrency(amount) {
        return `$${this.formatNumber(amount)}`;
    }

    debounce(func, wait) {
        let timeout;
        return function executedFunction(...args) {
            const later = () => {
                clearTimeout(timeout);
                func(...args);
            };
            clearTimeout(timeout);
            timeout = setTimeout(later, wait);
        };
    }
}

// Initialize the UI when the page loads
document.addEventListener('DOMContentLoaded', () => {
    window.baseScriptUI = new BaseScriptUI();
});

// Example usage for testing in browser
if (typeof GetParentResourceName === 'undefined') {
    // Mock function for browser testing
    window.GetParentResourceName = () => 'base_script';
    
    // Simulate some test data
    setTimeout(() => {
        if (window.baseScriptUI) {
            window.baseScriptUI.updatePlayerData({
                name: 'Test Player',
                money: 1500,
                bank: 5000,
                health: 150
            });
            window.baseScriptUI.showUI();
        }
    }, 1000);
}
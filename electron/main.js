const { app, BrowserWindow, Menu } = require('electron');
const path = require('path');

let mainWindow;

function createWindow() {
  // 创建浏览器窗口
  mainWindow = new BrowserWindow({
    width: 1400,
    height: 900,
    minWidth: 1000,
    minHeight: 600,
    title: 'NwServer 游戏服务器使用说明书',
    icon: path.join(__dirname, 'icon.ico'),
    webPreferences: {
      nodeIntegration: false,
      contextIsolation: false,  // 允许主进程执行页面脚本
      webSecurity: true,
      // 允许加载本地文件
      allowRunningInsecureContent: false
    },
    autoHideMenuBar: false,
    backgroundColor: '#f5f5f5'
  });

  // 加载 index.html
  mainWindow.loadFile('index.html');

  // 创建自定义菜单
  const menuTemplate = [
    {
      label: '文件',
      submenu: [
        {
          label: '刷新',
          accelerator: 'F5',
          click: () => {
            mainWindow.reload();
          }
        },
        {
          type: 'separator'
        },
        {
          label: '退出',
          accelerator: 'Alt+F4',
          click: () => {
            app.quit();
          }
        }
      ]
    },
    {
      label: '查看',
      submenu: [
        {
          label: '实际大小',
          accelerator: 'CmdOrCtrl+0',
          click: () => {
            mainWindow.webContents.setZoomLevel(0);
          }
        },
        {
          label: '放大',
          accelerator: 'CmdOrCtrl+Plus',
          click: () => {
            const currentZoom = mainWindow.webContents.getZoomLevel();
            mainWindow.webContents.setZoomLevel(currentZoom + 0.5);
          }
        },
        {
          label: '缩小',
          accelerator: 'CmdOrCtrl+-',
          click: () => {
            const currentZoom = mainWindow.webContents.getZoomLevel();
            mainWindow.webContents.setZoomLevel(currentZoom - 0.5);
          }
        },
        {
          type: 'separator'
        },
        {
          label: '全屏',
          accelerator: 'F11',
          click: () => {
            mainWindow.setFullScreen(!mainWindow.isFullScreen());
          }
        }
      ]
    },
    {
      label: '搜索',
      submenu: [
        {
          label: '搜索文档',
          accelerator: 'CmdOrCtrl+F',
          click: () => {
            // 调用页面中的搜索对话框
            mainWindow.webContents.executeJavaScript(`
              if (typeof showElectronSearch === 'function') {
                showElectronSearch();
              }
            `).catch(err => {
              console.error('打开搜索对话框失败:', err);
            });
          }
        }
      ]
    },
    {
      label: '帮助',
      submenu: [
        {
          label: '关于',
          click: () => {
            const { dialog } = require('electron');
            dialog.showMessageBox(mainWindow, {
              type: 'info',
              title: '关于 NwServer 使用说明书',
              message: 'NwServer 游戏服务器使用说明书',
              detail: '版本: 1.0.0\n\n本说明书记录了 NwServer 游戏服务器的脚本编写、系统配置、功能使用等内容。\n\n© 2025 NwServer Team',
              buttons: ['确定']
            });
          }
        }
      ]
    }
  ];

  const menu = Menu.buildFromTemplate(menuTemplate);
  Menu.setApplicationMenu(menu);

  // 窗口关闭时的处理
  mainWindow.on('closed', () => {
    mainWindow = null;
  });

  // 监听页面加载完成
  mainWindow.webContents.on('did-finish-load', () => {
    console.log('文档已加载完成');
  });

  // 阻止新窗口打开（在默认浏览器中打开外部链接）
  mainWindow.webContents.setWindowOpenHandler(({ url }) => {
    // 如果是外部链接，在系统默认浏览器中打开
    if (url.startsWith('http://') || url.startsWith('https://')) {
      require('electron').shell.openExternal(url);
      return { action: 'deny' };
    }
    return { action: 'allow' };
  });
}

// 当 Electron 完成初始化时创建窗口
app.whenReady().then(() => {
  createWindow();

  app.on('activate', () => {
    // 在 macOS 上，当点击 dock 图标且没有其他窗口打开时，
    // 通常会在应用程序中重新创建一个窗口
    if (BrowserWindow.getAllWindows().length === 0) {
      createWindow();
    }
  });
});

// 当所有窗口关闭时退出应用
app.on('window-all-closed', () => {
  // 在 macOS 上，除非用户用 Cmd + Q 确定地退出，
  // 否则绝大部分应用及其菜单栏会保持激活
  if (process.platform !== 'darwin') {
    app.quit();
  }
});

// 在这个文件中你可以包含应用程序其他特定的主进程代码
// 也可以把它们放在分离的文件中然后在这里引用

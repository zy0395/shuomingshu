// 切换子菜单
function toggleSubmenu(menuId, evt) {
    // 使用传入的事件对象或全局event
    const e = evt || event;
    const menu = document.getElementById(menuId);
    const parentItem = e.target.closest('.nav-item');
    
    if (menu && parentItem) {
        // 切换菜单状态（CSS会自动处理过渡动画）
        const isActive = menu.classList.contains('active');
        menu.classList.toggle('active');
        parentItem.classList.toggle('active');
        
        // 调试信息
        console.log(`目录 "${menuId}" ${isActive ? '折叠' : '展开'}`);
    }
    
    // 阻止事件冒泡，防止触发父级菜单
    e.stopPropagation();
}

// 加载页面到iframe
function loadPage(pageUrl) {
    const frame = document.getElementById('contentFrame');
    frame.src = pageUrl;
    
    // 获取点击的导航项
    const clickedItem = event.target.closest('.nav-item');
    
    // 只移除非父级菜单的active状态
    document.querySelectorAll('.nav-item').forEach(item => {
        // 如果不是has-submenu类型的项，移除active
        if (!item.classList.contains('has-submenu')) {
            item.classList.remove('active');
        }
    });
    
    // 为当前点击的项添加active
    if (clickedItem && !clickedItem.classList.contains('has-submenu')) {
        clickedItem.classList.add('active');
        
        // 确保父级菜单保持展开状态
        let parent = clickedItem.closest('.submenu, .sub-submenu');
        while (parent) {
            parent.classList.add('active');
            const parentNav = parent.previousElementSibling;
            if (parentNav && parentNav.classList.contains('nav-item')) {
                parentNav.classList.add('active');
            }
            parent = parent.parentElement.closest('.submenu, .sub-submenu');
        }
    }
    
    // 阻止事件冒泡
    event.stopPropagation();
}

// 搜索功能
function searchContent() {
    const searchText = document.getElementById('searchInput').value.toLowerCase();
    const navItems = document.querySelectorAll('.nav-item');
    
    navItems.forEach(item => {
        const text = item.textContent.toLowerCase();
        if (text.includes(searchText)) {
            item.style.display = 'block';
            // 展开父级菜单
            let parent = item.closest('.submenu, .sub-submenu');
            if (parent) {
                parent.classList.add('active');
                parent.previousElementSibling?.classList.add('active');
            }
        } else {
            // 如果是菜单项且没有子菜单，隐藏
            if (!item.classList.contains('has-submenu')) {
                item.style.display = searchText ? 'none' : 'block';
            }
        }
    });
}

// 页面加载完成
window.addEventListener('load', function() {
    console.log('NwServer文档系统加载完成');
});

[English](README.md) | 简体中文

# drcom.sh

drcom.sh 用于处理强制门户的状态检查和登录。

## 工作原理

1. **重定向检测**：尝试访问测试端点并检查是否有任何重定向。
2. **门户预测**：遍历可用的门户脚本来预测正确的门户类型。
3. **自动登录**：预测后，执行门户脚本中定义的登录过程。

## 依赖

- **bash**：用于执行脚本。
- **curl**：用于发送网络请求和处理响应。
- **grep、sed、awk**：用于过滤、转换和提取特定信息。

## 安装

1. **克隆仓库**：

   ```bash
   git clone https://github.com/Chihsiao/drcom.sh.git
   cd drcom.sh
   ```

2. **创建凭证配置**：

   创建一个包含登录凭证的配置文件：

   ```bash
   cat <<EOF > your_username.conf
   export DRCOM_USER="your_username"
   export DRCOM_PASS="your_password"
   EOF
   ```

3. **创建门户类型**

   若要支持新的门户类型，请在 `portals` 目录中创建一个新的脚本，并实现 `predict` 和 `login`。

   <details>
   <summary>示例</summary>

   ```bash
   case "$1" in
     "predict")
       # 查看 drcom.sh 以获取更多变量和函数
       @match "$redirect_url" -E '^http://example\.com/login\b'
     ;;
     "login")
       _request -X POST "http://example.com/login" \
           --url-encoded "username=$DRCOM_USER" \
           --url-encoded "password=$DRCOM_PASS" \
           -o /dev/null
     ;;
   esac
   ```
   </details>

## 使用方法

使用所需命令运行脚本：

- **检查状态**：

  ```bash
  ./drcom.sh your_username.conf status
  ```

- **登录**：

  ```bash
  ./drcom.sh your_username.conf try_to_login
  ```

## 许可证

本项目采用 MIT 许可证。详情请参阅 [LICENSE](LICENSE) 文件。

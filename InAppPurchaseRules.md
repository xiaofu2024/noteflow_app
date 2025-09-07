

VIP benefits and In App Purchase Rules


```
enum VipLevel {
// @String(普通用户)
VL_VIP_0 = 0;
// @String(普通会员)
VL_VIP_1 = 1;
// @String(高级会员)
VL_VIP_2 = 2;
// @String(至尊会员)
VL_VIP_3 = 3;
}

enum ExportData {
None = 0; // 禁止导出
Note = 1; // 导出笔记
Setting = 2; // 导出设置
NoteAndSetting = 3; // 导出笔记+设置
All = 4;  // 导出所有
}

```

``` Api Urls
Api baseUrl = https://shl-api.weletter01.com

//获取IAP配置，VIP等级
{{baseUrl}}/v1/app/user/getIapConfig 
//Response Data
{
    "status": {
        "code": 0,
        "group": 0,
        "message": ""
    },
    "data": {
        "goods": [
            {
                "id": 1,
                "productId": "",
                "level": "VL_VIP_0",
                "ocrLimit": 5,
                "noteCreateLimit": 0,
                "speechLimit": 2,
                "aiLimit": 1,
                "exportData": "None",
                "hasTemplate": false,
                "period": 0,
                "price": 0
            },
            {
                "id": 3,
                "productId": "com.shenghua.note.vip1",
                "level": "VL_VIP_1",
                "ocrLimit": -1,
                "noteCreateLimit": 10,
                "speechLimit": 10,
                "aiLimit": 5,
                "exportData": "Note",
                "hasTemplate": true,
                "period": 30,
                "price": 388
            },
            {
                "id": 5,
                "productId": "com.shenghua.note.vip2",
                "level": "VL_VIP_2",
                "ocrLimit": -1,
                "noteCreateLimit": 50,
                "speechLimit": 60,
                "aiLimit": 10,
                "exportData": "Setting",
                "hasTemplate": true,
                "period": 30,
                "price": 588
            },
            {
                "id": 7,
                "productId": "com.shenghua.note.vip3",
                "level": "VL_VIP_3",
                "ocrLimit": -1,
                "noteCreateLimit": -1,
                "speechLimit": -1,
                "aiLimit": -1,
                "exportData": "NoteAndSetting",
                "hasTemplate": true,
                "period": 16,
                "price": 688
            }
        ]
    }
}
字段含义解释：
level: VIP等级
ocrLimit: OCR识别次数，-1表示无限制
noteCreateLimit: 笔记创建数量，-1表示无限制
speechLimit: 语音转文字次数，-1表示无限制
aiLimit: AI使用次数，-1表示无限制，10表示10次 （此字段暂时忽略，以后的版本可能用上）
exportData: 这是数据导出权限，None表示禁止导出，Note表示只导出笔记，Setting表示导出设置，NoteAndSetting表示导出笔记+设置，All表示导出功能中的四个选项都可以用。
hasTemplate: 是否有模板权限（此内购暂时忽略）
period: 订阅周期，单位为天，0表示非订阅，可以设置任意天数，到期后自动失去VIP资格，需要另外购买。
price: 价格，1表示1分，显示的时候要转换为圆，即101要显示为¥1.01。

普通会员388/月
高级会员588/月
至尊会员688/16天


```
# BE_Aira2
BE_Aira2

## 설치

Create and activate a <a href="https://fastapi.tiangolo.com/virtual-environments/" class="external-link" target="_blank">가상 환경</a> 셋팅 이후 FASTAPI 설치:

<div class="termy">

```console
$ pip install "fastapi[standard]"

---> 100%
```

</div>

---

### 실행

서버 실행하기:

<div class="termy">

```console
$ fastapi dev main.py

 ╭────────── FastAPI CLI - Development mode ───────────╮
 │                                                     │
 │  Serving at: http://127.0.0.1:8000                  │
 │                                                     │
 │  API docs: http://127.0.0.1:8000/docs               │
 │                                                     │
 │  Running in development mode, for production use:   │
 │                                                     │
 │  fastapi run                                        │
 │                                                     │
 ╰─────────────────────────────────────────────────────╯

INFO:     Will watch for changes in these directories: ['/home/user/code/awesomeapp']
INFO:     Uvicorn running on http://127.0.0.1:8000 (Press CTRL+C to quit)
INFO:     Started reloader process [2248755] using WatchFiles
INFO:     Started server process [2248757]
INFO:     Waiting for application startup.
INFO:     Application startup complete.
```

</div>

---
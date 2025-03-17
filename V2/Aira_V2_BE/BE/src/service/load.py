def load_heavy_service():
    total = 0
    for i in range(10**8):
        total += i
    return {"status": "completed", "total": total} 
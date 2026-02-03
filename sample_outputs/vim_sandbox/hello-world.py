#!/usr/bin/env python3
def main():
    print("Hello, world")

if __name__ == "__main__":
    main()

def test_hello_world():
    assert "Hello, world" in main()

test_hello_world()

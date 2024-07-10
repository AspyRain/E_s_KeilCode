package com.example.qqfuturecontroller.entity;

public class BTdevice {
    private int id;
    private String name;
    private boolean state;
    private String address;
    public BTdevice(int id, String name, String address,boolean state) {
        this.address = address;
        this.id = id;
        this.name = name;
        this.state = state;
    }

    public String getAddress() {
        return address;
    }

    public void setAddress(String address) {
        this.address = address;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public boolean isState() {
        return state;
    }

    public void setState(boolean state) {
        this.state = state;
    }
}

from rest_framework import serializers
from .models import Book

class BookSerializer(serializers.ModelSerializer):
    class Meta:
        model = Book
        fields = '__all__'
    
    def validate_pages(self, value):
        if value <= 0:
            raise serializers.ValidationError("Pages must be a positive number")
        return value